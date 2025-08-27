package kr.lolland.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import kr.lolland.dao.AuctionDao;

@Service
public class AuctionService {

    private final AuctionDao auctionDao;
    
    public AuctionService(AuctionDao auctionDao) {
        this.auctionDao = auctionDao;
    }

    public Map<String, Object> getAucByRandomCode(String randomCode){
        return auctionDao.selectAucMainByRandomCode(randomCode);
    }

    public boolean existsLeaderNick(Long aucSeq, String nick){
        Integer cnt = auctionDao.countLeaderByNick(aucSeq, nick);
        return cnt != null && cnt > 0;
    }

    @Transactional
    public void markLeaderOnline(Long aucSeq, String nick, String onlineYn){
        auctionDao.updateLeaderOnline(aucSeq, nick, onlineYn);
    }

    public Map<String, Object> getLobbySnapshot(Long aucSeq){
        Map<String, Object> r = new HashMap<>();

        // 리더 목록
        List<Map<String,Object>> leaders = auctionDao.selectLeaders(aucSeq);
        r.put("leaders", leaders);

        // 집계
        int leaderCnt = (leaders != null) ? leaders.size() : 0;   // 전체 리더 수
        int readyCnt  = 0;                                        // READY_YN='Y' 수
        int onlineCnt = 0;                                        // ONLINE_YN='Y' 수 (참고용)

        if (leaders != null) {
            for (Map<String,Object> m : leaders) {
                String ready  = String.valueOf(m.get("READY_YN"));
                String online = String.valueOf(m.get("ONLINE_YN"));
                if ("Y".equalsIgnoreCase(ready))  readyCnt++;
                if ("Y".equalsIgnoreCase(online)) onlineCnt++;
            }
        }

        // 스냅샷 필드 채우기 (프론트가 이 키들을 씀)
        r.put("leaderCnt", leaderCnt);
        r.put("readyCnt",  readyCnt);
        r.put("onlineCnt", onlineCnt); // 필요 없으면 제거해도 됨

        // 기존 유지
        r.put("viewers", new Object[0]);
        r.put("viewerCnt", 0);

        return r;
    }


    @Transactional
    public void toggleReady(Long aucSeq, String nick){
        auctionDao.toggleReady(aucSeq, nick);
    }

    public int countActiveAuctions(){
        return auctionDao.countActiveAuctions();
    }

    @Transactional
    public void startAuction(Long aucSeq){
        auctionDao.updateAucStatus(aucSeq, "ING");
    }
    
    @Transactional
    public void markLeaderReady(Long aucSeq, String nick, String yn){
        auctionDao.markLeaderReady(aucSeq, nick, yn);
    }
    
    @Transactional
    public void setLeaderReady(Long aucSeq, String nick, String readyYn) {
        auctionDao.setLeaderReady(aucSeq, nick, readyYn);
    }
    
    @Transactional
    public Map<String,Object> getStep3Snapshot(Long aucSeq){
        auctionDao.insertMissingTeamsFromLeaders(aucSeq);

        List<Map<String,Object>> teams = auctionDao.selectTeamsByAuc(aucSeq);
        List<Map<String,Object>> players = auctionDao.selectNonLeaderPlayers(aucSeq);

        // 리더 티어/포지션 정보 추가
        List<Map<String,Object>> leaderDetails = auctionDao.selectLeaderDetails(aucSeq);
        Map<Long, Map<String,Object>> leaderByTeamId = new HashMap<>();
        for (Map<String,Object> m : leaderDetails){
            leaderByTeamId.put(((Number)m.get("TEAM_ID")).longValue(), m);
        }

        List<Long> order = loadOrCreateTeamOrder(aucSeq, teams);

        List<Map<String,Object>> orderedTeams = new ArrayList<>();
        int ord = 1;
        for (Long id : order) {
            Map<String,Object> base = new LinkedHashMap<>(teams.stream()
                    .filter(t -> ((Number)t.get("TEAM_ID")).longValue()==id).findFirst().orElse(new HashMap<>()));
            if (base.isEmpty()) continue;
            base.put("ORDER_NO", ord++);
            int budget = ((Number)base.get("BUDGET")).intValue();
            int left   = ((Number)base.get("BUDGET_LEFT")).intValue();
            base.put("USED", budget-left);

            // 리더 세부정보 merge
            Map<String,Object> detail = leaderByTeamId.get(id);
            if(detail!=null){
                base.put("LEADER_TIER",  detail.get("TIER"));
                base.put("LEADER_MROLE", detail.get("MROLE"));
                base.put("LEADER_SROLE", detail.get("SROLE"));
            }

            orderedTeams.add(base);
        }

        Map<String,Object> r = new LinkedHashMap<>();
        r.put("aucSeq", aucSeq);
        r.put("teams", orderedTeams);
        r.put("players", players);
        return r;
    }

    @SuppressWarnings("unchecked")
    private List<Long> loadOrCreateTeamOrder(Long aucSeq, List<Map<String,Object>> teams){
    	ObjectMapper objectMapper = new ObjectMapper();
        Map<String,Object> evt = auctionDao.selectLatestEventByType(aucSeq, "STEP3_INIT");
        if (evt != null && evt.get("PAYLOAD") != null) {
            try {
                Map<String,Object> payload = objectMapper.readValue(String.valueOf(evt.get("PAYLOAD")), Map.class);
                List<Number> saved = (List<Number>) payload.get("teamOrder");
                if (saved != null && !saved.isEmpty()) {
                    Set<Long> now = new HashSet<>();
                    for (Map<String,Object> t : teams) now.add(((Number)t.get("TEAM_ID")).longValue());
                    List<Long> casted = new ArrayList<>();
                    for (Number n : saved) casted.add(n.longValue());
                    if (now.equals(new HashSet<>(casted))) return casted; // 구성 동일 시 재사용
                }
            } catch(Exception ignore){}
        }
        // 생성
        List<Long> ids = new ArrayList<>();
        for (Map<String,Object> t : teams) ids.add(((Number)t.get("TEAM_ID")).longValue());
        Collections.shuffle(ids, new java.security.SecureRandom());
        // 저장
        try{
            Map<String,Object> payload = new HashMap<>();
            payload.put("teamOrder", ids);
            auctionDao.insertEvent(aucSeq, "STEP3_INIT", objectMapper.writeValueAsString(payload));
        }catch(Exception e){ throw new RuntimeException("STEP3_INIT 저장 실패", e); }
        return ids;
    }
    
    @Transactional
    public Map<String,Object> initRoundAndBeginFirstPick(Long aucSeq){
        Map<String,Object> r1 = auctionDao.selectRoundByNo(aucSeq, 1);
        if (r1 == null) { auctionDao.insertRound(aucSeq, 1); r1 = auctionDao.selectRoundByNo(aucSeq, 1); }
        Long roundId = ((Number)r1.get("ROUND_ID")).longValue();
        auctionDao.updateRoundStatus(roundId, "ING");

        if (auctionDao.selectNextReadyPick(aucSeq) == null) {
            int no = 1;
            for (Map<String,Object> p : auctionDao.selectPlayersForPick(aucSeq)) {
                auctionDao.insertPick(roundId, aucSeq, no++, String.valueOf(p.get("NICK")));
            }
        }
        Map<String,Object> pick = auctionDao.selectNextReadyPick(aucSeq);
        if (pick == null) throw new IllegalStateException("READY 픽 없음");
        Long pickId = ((Number)pick.get("PICK_ID")).longValue();
        auctionDao.beginPick(pickId);

        Map<String,Object> snap = new HashMap<>();
        snap.put("pickId", pickId);
        snap.put("targetNick", pick.get("TARGET_NICK"));
        snap.put("highestBid", 0);
        snap.put("deadlineTs", System.currentTimeMillis()+7000);
        return snap;
    }

    private int incFor(int price){ return price<100?10 : price<400?20 : 50; }

    public Map<String,Object> getControls(Long aucSeq, Long teamId, Long pickId){
        Map<String,Object> pick = auctionDao.selectPickById(pickId);
        Map<String,Object> team = auctionDao.selectTeamById(teamId);
        int current = ((Number)pick.get("HIGHEST_BID")).intValue();
        int left    = ((Number)team.get("BUDGET_LEFT")).intValue();

        List<Integer> incs = new ArrayList<>();
        int minInc = incFor(current);
        for (int c : new int[]{10,20,50}) {
            if (c >= minInc && current + c <= left) incs.add(c);
        }
        Map<String,Object> r = new HashMap<>();
        r.put("current", current);
        r.put("enabledIncs", incs);
        r.put("canAllin", left > current);
        return r;
    }

    @Transactional
    public Map<String,Object> placeBid(Long aucSeq, Long pickId, Long teamId, String nick,
                                       int amount, boolean allin){
        Map<String,Object> pick = auctionDao.selectPickById(pickId);
        if (!"BIDDING".equals(String.valueOf(pick.get("STATUS")))) throw new IllegalStateException("입찰 불가");
        int current = ((Number)pick.get("HIGHEST_BID")).intValue();
        int version = ((Number)pick.get("VERSION")).intValue();

        Map<String,Object> team = auctionDao.selectTeamById(teamId);
        int left = ((Number)team.get("BUDGET_LEFT")).intValue();

        if (allin) { if (left <= current) throw new IllegalArgumentException("올인 불가"); amount = left; }
        else {
        	int target = amount;
        	int tmp = current;
        	while (tmp < target) {
        	    tmp += incFor(tmp);
        	}
        	if (tmp != target) {
        	    throw new IllegalArgumentException("증분 불일치");
        	}
            if (amount > left) throw new IllegalArgumentException("잔액 부족");
        }
        if (amount <= current) throw new IllegalArgumentException("동점/낮은 금액");

        auctionDao.insertBid(aucSeq, pickId, teamId, nick, amount, allin?"Y":"N");
        if (auctionDao.updatePickHighest(pickId, amount, teamId, version) == 0)
            throw new IllegalStateException("경합 실패");

        Map<String,Object> snap = new HashMap<>();
        snap.put("pickId", pickId);
        snap.put("targetNick", pick.get("TARGET_NICK"));
        snap.put("highestBid", amount);
        snap.put("highestTeam", teamId);
        snap.put("deadlineTs", System.currentTimeMillis()+7000);
        return snap;
    }

    @Transactional
    public Map<String,Object> finalizePick(Long aucSeq, Long pickId){
    	Map<String,Object> pick = auctionDao.selectPickById(pickId);
        Long roundId = ((Number)pick.get("ROUND_ID")).longValue();
        String target = String.valueOf(pick.get("TARGET_NICK"));
        int highest = ((Number)pick.get("HIGHEST_BID")).intValue();
        Number highestTeamN = (Number)pick.get("HIGHEST_TEAM");

        Map<String,Object> out = new HashMap<>();
        if (highestTeamN == null) { // 무입찰
            auctionDao.skipPick(pickId);
            auctionDao.incrementSkip(pickId);
            int skip = ((Number)auctionDao.selectPickById(pickId).get("SKIP_COUNT")).intValue();
            if (skip >= 2) { // 0포 배정
                auctionDao.assignPick(pickId);
                out.put("assigned", false);
            } else { // 맨 뒤 재배치
                int nextNo = 1 + ((Number)auctionDao.selectMaxPickNo(roundId).get("MAX_NO")).intValue();
                auctionDao.appendRequeuedPick(roundId, aucSeq, target, nextNo);
                out.put("requeued", true);
            }
        } else { // 낙찰 확정
        	Long teamId = highestTeamN.longValue();
            // 예산 차감
            if (auctionDao.updateTeamBudget(teamId, highest) == 0) throw new IllegalStateException("예산 부족/경합");

            // 팀원 등록
            auctionDao.insertTeamMember(teamId, aucSeq, target, highest, pickId);

            // 픽 상태 ASSIGNED
            auctionDao.assignPick(pickId);

            // 팀 정보 재조회(남은 예산)
            Map<String,Object> team = auctionDao.selectTeamById(teamId);
            int left = ((Number)team.get("BUDGET_LEFT")).intValue();

            out.put("assigned", true);
            out.put("price", highest);
            out.put("teamId", teamId);
            out.put("targetNick", target);
            out.put("teamBudgetLeft", left);

            // (선택) 팀장 닉 (프론트에서 내팀 매칭용)
            out.put("leaderNick", String.valueOf(team.get("LEADER_NICK")));
        }

        Map<String,Object> next = auctionDao.selectNextReadyPick(aucSeq);
        if (next != null) {
            auctionDao.beginPick(((Number)next.get("PICK_ID")).longValue());
            out.put("nextPickId", next.get("PICK_ID"));
            out.put("nextTarget", next.get("TARGET_NICK"));
            out.put("deadlineTs", System.currentTimeMillis()+7000);
        } else {
            auctionDao.updateRoundStatus(roundId, "END");
            out.put("roundEnd", true);
        }
        return out;
    }
    
 // 진행 중 픽이 있으면 스냅샷 반환, 없으면 null
    public Map<String,Object> findCurrentPickSnapshot(Long aucSeq){
        Map<String,Object> pick = auctionDao.selectCurrentBiddingPick(aucSeq); // STATUS='BIDDING' 1건
        if (pick == null) return null;
        Map<String,Object> snap = new HashMap<>();
        snap.put("pickId", pick.get("PICK_ID"));
        snap.put("targetNick", pick.get("TARGET_NICK"));
        snap.put("highestBid", ((Number)pick.get("HIGHEST_BID")).intValue());
        // 남은시간은 서버 메모리 타이머를 쓰는 구조라면 runtime에서 계산, 없으면 임시로 now+7000
        snap.put("deadlineTs", System.currentTimeMillis()+7000);
        return snap;
    }

    public void logEvent(Long aucSeq, String type, Object payload){
        try{
        	ObjectMapper objectMapper = new ObjectMapper();
            String json = objectMapper.writeValueAsString(payload);
            auctionDao.insertEvent(aucSeq, type, json);
        }catch(Exception ignore){}
    }

    public Long findTeamIdByLeader(Long aucSeq, String nick){
        return auctionDao.findTeamIdByLeader(aucSeq, nick);
    }

    @Transactional
    public Map<String,Object> openNextPickIfAny(Long aucSeq){
        Map<String,Object> next = auctionDao.selectNextReadyPick(aucSeq);
        if (next == null) return null;
        Long pickId = ((Number)next.get("PICK_ID")).longValue();
        auctionDao.beginPick(pickId);

        Map<String,Object> snap = new java.util.HashMap<>();
        snap.put("pickId", pickId);
        snap.put("targetNick", next.get("TARGET_NICK"));
        snap.put("highestBid", 0);
        snap.put("deadlineTs", System.currentTimeMillis()+7000);
        return snap;
    }

    /** 입찰 시 마다 데드라인 연장/브로드캐스트용 헬퍼 (선택) */
    public long newDeadlineTs() {
        return System.currentTimeMillis()+7000;
    }


}
