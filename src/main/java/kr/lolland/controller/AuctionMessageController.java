package kr.lolland.controller;

import java.util.Map;

import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.RestController;

import kr.lolland.service.AuctionService;

@RestController
public class AuctionMessageController {

    private final AuctionService auctionService;
    private final SimpMessagingTemplate msg;

    public AuctionMessageController(AuctionService auctionService, SimpMessagingTemplate msg) {
        this.auctionService = auctionService;
        this.msg = msg;
    }

    @MessageMapping("/lobby.{aucSeq}.ready")
    public void ready(@DestinationVariable Long aucSeq, SimpMessageHeaderAccessor headers) {
        String nick = (String) headers.getSessionAttributes().get("NICK");
        if (nick == null) return;
        auctionService.markLeaderReady(aucSeq, nick, "Y");
        Map<String,Object> snap = auctionService.getLobbySnapshot(aucSeq);
        msg.convertAndSend("/topic/lobby."+aucSeq, snap);
    }

    @MessageMapping("/lobby.{aucSeq}.start")
    public void start(@DestinationVariable Long aucSeq, SimpMessageHeaderAccessor headers) {
        auctionService.startAuction(aucSeq);
        Map<String,Object> snap = auctionService.getLobbySnapshot(aucSeq);
        msg.convertAndSend("/topic/lobby."+aucSeq, snap);
    }
    
    @MessageMapping("/lobby.{aucSeq}.unready")
    public void unready(@DestinationVariable Long aucSeq,
                        SimpMessageHeaderAccessor headers) {
        String nick = (String) headers.getSessionAttributes().get("NICK");
        if (nick == null) return;
        auctionService.setLeaderReady(aucSeq, nick, "N");

        Map<String,Object> snap = auctionService.getLobbySnapshot(aucSeq);
        msg.convertAndSend("/topic/lobby."+aucSeq, snap);
    }
}
