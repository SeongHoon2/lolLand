package kr.lolland.controller;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import kr.lolland.service.AuctionService;

@RestController
@RequestMapping("/api/auction")
public class AuctionController {

    private final AuctionService auctionService;
    private final SimpMessagingTemplate msg;
    private final AuctionAutoRunner autoRunner;

    public AuctionController(AuctionService auctionService,
                             SimpMessagingTemplate msg,
                             AuctionAutoRunner autoRunner) {
        this.auctionService = auctionService;
        this.msg = msg;
        this.autoRunner = autoRunner;
    }

    private static final java.util.Set<String> ADMIN_WHITELIST =
            new java.util.HashSet<String>(java.util.Arrays.asList("admin", "tjdgns"));

    private static boolean isAdminNick(String nick) {
        return nick != null && ADMIN_WHITELIST.contains(nick.trim().toLowerCase(java.util.Locale.ROOT));
    }

    @PostMapping("/{code}/lobby/join")
    public Map<String, Object> joinLobby(@PathVariable("code") String code,
                                         @RequestBody Map<String, Object> body,
                                         HttpSession session) {
        String rawNick = String.valueOf(body.getOrDefault("nick", "")).trim();
        if (code == null || code.trim().isEmpty() || rawNick.isEmpty()) return resp(false, "코드/닉네임 누락");

        String nick = rawNick;
        Map<String, Object> auc = auctionService.getAucByRandomCode(code);
        if (auc == null) return resp(false, "존재하지 않는 입장 코드");

        String status = String.valueOf(auc.get("A_STATUS"));
        if (!"WAIT".equals(status)&&!"ING".equals(status)) return resp(false, "입장 불가 상태입니다.");

        Long aucSeq = ((Number) auc.get("SEQ")).longValue();

        // ======== 관리자 고스트 분기 ========
        if (isAdminNick(nick)) {
            // DB 변경 없음 (AUC_MEMBER 기록 X)
            session.setAttribute("AUC_SEQ", aucSeq);
            session.setAttribute("AUC_CODE", code);
            session.setAttribute("NICK", nick);
            session.setAttribute("ROLE", "ADMIN_GHOST");
        } else {
            // ======== 기존 리더 입장 로직 ========
            if (!auctionService.existsLeaderNick(aucSeq, nick)) {
                return resp(false, "참가 자격이 없습니다. 닉네임을 확인하세요.");
            }
            auctionService.markLeaderOnline(aucSeq, nick, "Y"); // DB 반영
            session.setAttribute("AUC_SEQ", aucSeq);
            session.setAttribute("AUC_CODE", code);
            session.setAttribute("NICK", nick);
            session.setAttribute("ROLE", "LEADER");
        }

        // 입장 즉시 스냅샷 브로드캐스트
        Map<String,Object> snap = auctionService.getLobbySnapshot(aucSeq);
        msg.convertAndSend("/topic/lobby."+aucSeq, snap);

        Map<String, Object> data = new java.util.HashMap<String, Object>();
        data.put("aucSeq", aucSeq);
        data.put("code", code);
        data.put("nick", nick);
        data.put("role", session.getAttribute("ROLE"));

        // 현재 경매 상태 포함
        Map<String, Object> auc2 = auctionService.getAucByRandomCode(code);
        if (auc2 != null) data.put("status", auc2.get("A_STATUS"));

        // 스냅샷 키(leaderCnt/readyCnt) 포함
        data.putAll(auctionService.getLobbySnapshot(aucSeq));

        return resp(true, null, data);
    }

    @PostMapping("/{code}/lobby/exit")
    public Map<String, Object> exitLobby(@PathVariable("code") String code,
                                         @RequestBody(required=false) Map<String, Object> body,
                                         HttpSession session) {
        Object sAucSeq = session.getAttribute("AUC_SEQ");
        Object sCode   = session.getAttribute("AUC_CODE");
        Object sNick   = session.getAttribute("NICK");
        if (sAucSeq == null || sNick == null || sCode == null) return resp(false, "세션 없음");
        if (!String.valueOf(sCode).equals(code)) return resp(false, "코드 불일치");

        Long aucSeq = ((Number) sAucSeq).longValue();
        String nick = String.valueOf(sNick);

        // 오프라인 표시
        auctionService.markLeaderOnline(aucSeq, nick, "N");
        auctionService.setLeaderReady(aucSeq, nick, "N");

        session.removeAttribute("AUC_SEQ");
        session.removeAttribute("AUC_CODE");
        session.removeAttribute("NICK");

        // 나가기 즉시 스냅샷 브로드캐스트
        Map<String,Object> snap = auctionService.getLobbySnapshot(aucSeq);
        msg.convertAndSend("/topic/lobby."+aucSeq, snap);

        return resp(true, null, null);
    }

    @GetMapping("/{code}/overview")
    public Map<String, Object> overview(@PathVariable("code") String code) {
        Map<String, Object> auc = auctionService.getAucByRandomCode(code);
        if (auc == null) return resp(false, "존재하지 않는 경매 코드");
        Long aucSeq = ((Number) auc.get("SEQ")).longValue();
        Map<String, Object> data = new HashMap<>();
        data.put("aucSeq", aucSeq);
        data.put("status", auc.get("A_STATUS"));
        data.putAll(auctionService.getLobbySnapshot(aucSeq));
        return resp(true, null, data);
    }

    private Map<String, Object> resp(boolean success, String msg){ return resp(success, msg, null); }
    private Map<String, Object> resp(boolean success, String msg, Object data){
        Map<String,Object> m = new HashMap<>();
        m.put("success", success);
        if(!success && msg!=null){
            Map<String,Object> e = new HashMap<>();
            e.put("msg", msg);
            m.put("error", e);
        }
        if(data!=null) m.put("data", data);
        return m;
    }

    @GetMapping("/restore")
    public Map<String, Object> restore(HttpSession session) {
        Object sAucSeq = session.getAttribute("AUC_SEQ");
        Object sCode   = session.getAttribute("AUC_CODE");
        Object sNick   = session.getAttribute("NICK");
        if (sAucSeq == null || sCode == null || sNick == null) {
            return resp(false, "no session");
        }

        Long aucSeq = ((Number) sAucSeq).longValue();
        String code = String.valueOf(sCode);
        String nick = String.valueOf(sNick);

        // 새로고침으로 끊겼다가 다시 들어온 경우 ONLINE 다시 Y로
        auctionService.markLeaderOnline(aucSeq, nick, "Y");

        Map<String, Object> data = new HashMap<>();
        data.put("aucSeq", aucSeq);
        data.put("code", code);
        data.put("nick", nick);

        // 현재 경매 상태 포함
        Map<String, Object> auc = auctionService.getAucByRandomCode(code);
        if (auc != null) data.put("status", auc.get("A_STATUS"));

        // 스냅샷 포함
        data.putAll(auctionService.getLobbySnapshot(aucSeq));

        return resp(true, null, data);
    }

    @PostMapping("/{code}/lobby/start")
    public Map<String, Object> startAuction(@PathVariable("code") String code, HttpSession session) {
        Object sAucSeq = session.getAttribute("AUC_SEQ");
        Object sCode   = session.getAttribute("AUC_CODE");
        Object sRole   = session.getAttribute("ROLE");
        if (sAucSeq == null || sCode == null || sRole == null) return resp(false, "세션 없음");
        if (!String.valueOf(sCode).equals(code)) return resp(false, "코드 불일치");
        if (!"ADMIN_GHOST".equals(String.valueOf(sRole))) return resp(false, "권한 없음");

        Map<String, Object> auc = auctionService.getAucByRandomCode(code);
        if (auc == null) return resp(false, "경매 없음");
        if (!"WAIT".equals(String.valueOf(auc.get("A_STATUS")))) return resp(false, "WAIT 상태에서만 시작 가능");

        Long aucSeq = ((Number) sAucSeq).longValue();
        Map<String,Object> snap = auctionService.getLobbySnapshot(aucSeq);
        int onlineCnt = (snap.get("onlineCnt") instanceof Number) ? ((Number)snap.get("onlineCnt")).intValue() : 0;
        int readyCnt  = (snap.get("readyCnt")  instanceof Number) ? ((Number)snap.get("readyCnt")).intValue()  : 0;
        if (onlineCnt <= 0) return resp(false, "모든 인원이 온라인이 아닙니다.");
        if (onlineCnt != readyCnt) return resp(false, "모든 인원이 준비완료가 아닙니다.");

        // 상태 전환: WAIT -> ING
        auctionService.startAuction(aucSeq);

        // 1) 스냅샷 갱신 브로드캐스트
        Map<String,Object> snap2 = auctionService.getLobbySnapshot(aucSeq);
        msg.convertAndSend("/topic/lobby."+aucSeq, snap2);

        // 2) 상태 전환 브로드캐스트 → 클라이언트 STEP3 전환 유도
        Map<String,Object> stateMsg = new java.util.HashMap<>();
        stateMsg.put("status", "ING");
        stateMsg.put("aucSeq", aucSeq);
        stateMsg.put("code", code);
        msg.convertAndSend("/topic/lobby."+aucSeq, stateMsg);

        return resp(true, null, null);
    }

    @GetMapping("/{code}/step3/snapshot")
    public Map<String,Object> step3Snapshot(@PathVariable("code") String code){
        Map<String, Object> auc = auctionService.getAucByRandomCode(code);
        if (auc == null) return resp(false, "존재하지 않는 경매 코드");
        if (!"ING".equals(String.valueOf(auc.get("A_STATUS")))) return resp(false, "ING 상태가 아님");

        Long aucSeq = ((Number)auc.get("SEQ")).longValue();
        Map<String,Object> data = auctionService.getStep3Snapshot(aucSeq);
        return resp(true, null, data);
    }

    @PostMapping("/{code}/step3/begin")
    public Map<String,Object> begin(@PathVariable String code, HttpSession s){
        // 1) 권한 확인
        if (!"ADMIN_GHOST".equals(String.valueOf(s.getAttribute("ROLE")))) {
            return resp(false, "권한 없음");
        }
        // 2) 상태 확인
        Map<String,Object> auc = auctionService.getAucByRandomCode(code);
        if (auc == null) return resp(false, "경매 없음");
        if (!"ING".equals(String.valueOf(auc.get("A_STATUS")))) return resp(false, "ING 상태 아님");
        Long aucSeq = ((Number)auc.get("SEQ")).longValue();

        // 이미 진행 중이면 현 스냅샷 방송 + 자동루프 보장
        Map<String,Object> current = auctionService.findCurrentPickSnapshot(aucSeq);
        if (current != null) {
            msg.convertAndSend("/topic/auc."+aucSeq+".state", current);
            autoRunner.start(aucSeq); // 이미 돌고 있으면 내부에서 무시
            return resp(true, null, current);
        }

        // 첫 픽 오픈
        Map<String,Object> snap = auctionService.initRoundAndBeginFirstPick(aucSeq);
        msg.convertAndSend("/topic/auc."+aucSeq+".state", snap);

        // 자동 진행 시작
        autoRunner.start(aucSeq);

        return resp(true, null, snap);
    }

    @GetMapping("/{code}/picks/{pickId}/controls")
    public Map<String,Object> controls(@PathVariable String code,
                                       @PathVariable Long pickId,
                                       @org.springframework.web.bind.annotation.RequestParam(value="teamId", required=false) Long teamIdParam,
                                       HttpSession s){
        Map<String,Object> auc = auctionService.getAucByRandomCode(code);
        if (auc==null) return resp(false,"경매 없음");
        Long aucSeq = ((Number)auc.get("SEQ")).longValue();
        Long teamId;
        try {
            teamId = resolveTeamId(aucSeq, s, teamIdParam);
        } catch (Exception e) {
            return resp(false, e.getMessage());
        }
        return resp(true, null, auctionService.getControls(aucSeq, teamId, pickId));
    }

    @PostMapping("/{code}/picks/{pickId}/bid")
    public Map<String,Object> bid(@PathVariable String code, @PathVariable Long pickId,
                                  @RequestBody Map<String,Object> body,
                                  HttpSession s){
        Map<String,Object> auc = auctionService.getAucByRandomCode(code);
        if (auc==null) return resp(false,"경매 없음");
        Long aucSeq = ((Number)auc.get("SEQ")).longValue();

        // 관리자 테스트 편의를 위해 body.teamId 허용
        Long teamIdParam = body.get("teamId")==null ? null : ((Number)body.get("teamId")).longValue();
        Long teamId;
        try {
            teamId = resolveTeamId(aucSeq, s, teamIdParam);
        } catch (Exception e) {
            return resp(false, e.getMessage());
        }

        String nick = String.valueOf(s.getAttribute("NICK"));
        boolean allin = "Y".equalsIgnoreCase(String.valueOf(body.get("allin")));
        int amount = allin ? 0 : ((Number)body.get("amount")).intValue();

        try {
            Map<String,Object> snap = auctionService.placeBid(aucSeq, pickId, teamId, nick, amount, allin);
            msg.convertAndSend("/topic/auc."+aucSeq+".state", snap);

            // 입찰이 들어오면 7초 리셋 (오토러너에 위임)
            autoRunner.reset(aucSeq, ((Number)snap.get("pickId")).longValue(), 7);

            return resp(true, null, snap);
        } catch (Exception ex){
            return resp(false, ex.getMessage());
        }
    }

    // ===== 내부 공용 =====

    private Long resolveTeamId(Long aucSeq, HttpSession s, Long overrideForAdmin) {
        String role = String.valueOf(s.getAttribute("ROLE"));
        String nick = String.valueOf(s.getAttribute("NICK"));

        if ("ADMIN_GHOST".equals(role) && overrideForAdmin != null) {
            return overrideForAdmin;
        }
        Long teamId = auctionService.findTeamIdByLeader(aucSeq, nick);
        if (teamId == null) throw new IllegalStateException("팀 정보가 없습니다. (라운드 시작 전이거나 팀 생성 전)");
        return teamId;
    }
}
