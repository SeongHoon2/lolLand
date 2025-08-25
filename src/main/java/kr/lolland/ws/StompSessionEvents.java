package kr.lolland.ws;

import java.util.Map;

import org.springframework.context.ApplicationListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import kr.lolland.service.AuctionService;

@Component
public class StompSessionEvents implements ApplicationListener<SessionDisconnectEvent> {

    private final AuctionService auctionService;
    private final SimpMessagingTemplate msg;

    public StompSessionEvents(AuctionService auctionService, SimpMessagingTemplate msg) {
        this.auctionService = auctionService;
        this.msg = msg;
    }

    @Override
    public void onApplicationEvent(SessionDisconnectEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        Map<String, Object> attrs = accessor.getSessionAttributes();
        if (attrs == null) return;

        Object oSeq = attrs.get("AUC_SEQ");
        Object oNick = attrs.get("NICK");
        if (oSeq == null || oNick == null) return;

        long aucSeq = (oSeq instanceof Number) ? ((Number) oSeq).longValue() : Long.parseLong(String.valueOf(oSeq));
        String nick = String.valueOf(oNick);

        // 오프라인 처리
        auctionService.markLeaderOnline(aucSeq, nick, "N");

        // ✅ 끊김 즉시 스냅샷 브로드캐스트
        Map<String,Object> snap = auctionService.getLobbySnapshot(aucSeq);
        msg.convertAndSend("/topic/lobby."+aucSeq, snap);
    }
}
