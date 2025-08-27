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
}
