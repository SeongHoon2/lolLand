package kr.lolland.controller;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor; 
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import kr.lolland.service.AuctionService;
/*
@RestController
@RequestMapping("/auction")
public class AuctionController {

    private final AuctionService auctionService;
    private final SimpMessagingTemplate msg;

    public AuctionController(AuctionService auctionService, SimpMessagingTemplate msg) {
        this.auctionService = auctionService;
        this.msg = msg;
    }

    @PostMapping("/{code}/lobby/join")
    public Map<String, Object> joinLobby(@PathVariable("code") String code,
                                         @RequestBody Map<String, Object> body,
                                         HttpSession session) {
        String rawNick = String.valueOf(body.getOrDefault("nick", "")).trim();
        if (code == null || code.trim().isEmpty() || rawNick.isEmpty()) return resp(false, "코드/닉네임 누락");

        String nick = rawNick;
        Map<String, Object> auc = auctionService.getAucByRandomCode(code);
        if (auc == null) return resp(false, "존재하지 않는 경매 코드");

        String status = String.valueOf(auc.get("A_STATUS"));
        if (!"WAIT".equals(status)) return resp(false, "현재 상태(" + status + ")에서는 입장할 수 없습니다.");

        Long aucSeq = ((Number) auc.get("SEQ")).longValue();
        boolean leaderOk = auctionService.existsLeaderNick(aucSeq, nick);
        if (!leaderOk) return resp(false, "참가 자격이 없습니다. 팀장 닉네임을 확인하세요.");

        // 온라인 표시
        auctionService.markLeaderOnline(aucSeq, nick, "Y");

        // 세션 세팅
        session.setAttribute("AUC_SEQ", aucSeq);
        session.setAttribute("AUC_CODE", code);
        session.setAttribute("NICK", nick);
        session.setAttribute("ROLE", "LEADER");

        // ✅ 입장 즉시 스냅샷 브로드캐스트
        Map<String,Object> snap = auctionService.getLobbySnapshot(aucSeq);
        msg.convertAndSend("/topic/lobby."+aucSeq, snap);

        Map<String, Object> data = new HashMap<>();
        data.put("aucSeq", aucSeq);
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

        // ✅ 나가기 즉시 스냅샷 브로드캐스트
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
}*/
