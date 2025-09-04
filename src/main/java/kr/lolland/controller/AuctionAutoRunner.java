// src/main/java/kr/lolland/controller/AuctionAutoRunner.java
package kr.lolland.controller;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import kr.lolland.service.AuctionService;

@Component
public class AuctionAutoRunner {

    private final ScheduledExecutorService exec = Executors.newScheduledThreadPool(1);
    private final ConcurrentHashMap<Long, Entry> timers = new ConcurrentHashMap<>(); // aucSeq -> Entry
    private final AuctionService service;
    private final SimpMessagingTemplate msg;

    public AuctionAutoRunner(AuctionService service, SimpMessagingTemplate msg) {
        this.service = service;
        this.msg = msg;
    }

    private static class Entry {
        long aucSeq;
        long pickId;
        long deadlineTs;
        ScheduledFuture<?> fut;
    }

    /** 이미 같은 픽이 돌고 있으면 그대로 사용(마감시간 유지), 없으면 새로 시작 */
    public synchronized long start(Long aucSeq, Long pickId, int seconds){
        Entry e = timers.get(aucSeq);
        if (e != null && e.pickId == pickId && e.fut != null && !e.fut.isDone()) {
            return e.deadlineTs; // 유지
        }
        return schedule(aucSeq, pickId, seconds);
    }

    /** 입찰 발생 시 남은 시간 재설정 */
    public synchronized long reset(Long aucSeq, Long pickId, int seconds){
        return schedule(aucSeq, pickId, seconds);
    }

    /** 현재 마감시각 조회(없으면 null) */
    public Long peekDeadline(Long aucSeq){
        Entry e = timers.get(aucSeq);
        return (e == null) ? null : e.deadlineTs;
    }

    // ===== 내부 =====
    private long schedule(Long aucSeq, Long pickId, int seconds){
        cancel(aucSeq);
        Entry ne = new Entry();
        ne.aucSeq = aucSeq;
        ne.pickId = pickId;
        ne.deadlineTs = System.currentTimeMillis() + Math.max(1, seconds) * 1000L;
        ne.fut = exec.schedule(() -> finalizeAndBroadcast(aucSeq, pickId), Math.max(1, seconds), TimeUnit.SECONDS);
        timers.put(aucSeq, ne);
        return ne.deadlineTs;
    }

    private void cancel(Long aucSeq){
        Entry e = timers.remove(aucSeq);
        if (e != null && e.fut != null) {
            e.fut.cancel(false);
        }
    }

    private void finalizeAndBroadcast(Long aucSeq, Long pickId){
        try {
            Map<String,Object> out = service.finalizePick(aucSeq, pickId);
            cancel(aucSeq);
            msg.convertAndSend("/topic/auc."+aucSeq+".state", out);
            if (Boolean.TRUE.equals(out.get("finished")) || Boolean.TRUE.equals(out.get("auctionEnd"))) {
	               Map<String,Object> endMsg = new HashMap<>();
	               endMsg.put("status", "END");
	               endMsg.put("aucSeq", aucSeq);
	               msg.convertAndSend("/topic/lobby."+aucSeq, endMsg);
            }
        } catch (Exception ignore) {
            // 로깅만 필요 시 추가
        }
    }
}
