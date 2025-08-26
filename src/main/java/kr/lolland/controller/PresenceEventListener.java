package kr.lolland.controller;

import java.util.Map;

import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import kr.lolland.service.AuctionService;

@Component
public class PresenceEventListener {

    private final AuctionService auctionService;
    private final SimpMessagingTemplate msg;

    public PresenceEventListener(AuctionService auctionService, SimpMessagingTemplate msg) {
        this.auctionService = auctionService;
        this.msg = msg;
    }

    @EventListener
    public void onConnect(SessionConnectEvent event) {
        SimpMessageHeaderAccessor accessor = SimpMessageHeaderAccessor.wrap(event.getMessage());
        Map<String, Object> sess = accessor.getSessionAttributes();
        if (sess == null) return;

        Long aucSeq = (Long) sess.get("AUC_SEQ");
        String nick = (String) sess.get("NICK");
        if (aucSeq == null || nick == null) return;

        // 연결되면 온라인 표시(중복 호출 안전)
        auctionService.markLeaderOnline(aucSeq, nick, "Y");

        // 로비 스냅샷 브로드캐스트
        Map<String,Object> snap = auctionService.getLobbySnapshot(aucSeq);
        msg.convertAndSend("/topic/lobby."+aucSeq, snap);
    }

    @EventListener
    public void onDisconnect(SessionDisconnectEvent event) {
        SimpMessageHeaderAccessor accessor = SimpMessageHeaderAccessor.wrap(event.getMessage());
        Map<String, Object> sess = accessor.getSessionAttributes();
        if (sess == null) return;

        Long aucSeq = (Long) sess.get("AUC_SEQ");
        String nick = (String) sess.get("NICK");
        String role = (String) sess.get("ROLE");
        if (aucSeq == null || nick == null) return;

        if ("LEADER".equals(role)) {
            auctionService.markLeaderOnline(aucSeq, nick, "N");
            auctionService.markLeaderReady(aucSeq, nick, "N");
        }

        Map<String,Object> snap = auctionService.getLobbySnapshot(aucSeq);
        msg.convertAndSend("/topic/lobby."+aucSeq, snap);
    }
}
