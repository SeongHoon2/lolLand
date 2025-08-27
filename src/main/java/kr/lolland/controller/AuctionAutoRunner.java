package kr.lolland.controller;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import javax.annotation.PreDestroy;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import kr.lolland.service.AuctionService;

/**
 * 경매 자동 진행기:
 * - begin 시 첫 픽을 오픈(없으면 생성)하고 7초 타이머 시작
 * - 7초 만료되면 finalizePick() → 다음 READY가 있으면 즉시 브로드캐스트 + 다시 7초 타이머
 * - 입찰이 들어오면 reset(7초 재시작)
 */
@Component
public class AuctionAutoRunner {

    private final AuctionService auctionService;
    private final SimpMessagingTemplate msg;

    private final ScheduledExecutorService exec = Executors.newScheduledThreadPool(2);
    private final Map<Long, ScheduledFuture<?>> futures = new ConcurrentHashMap<>(); // aucSeq -> future
    private final Map<Long, Long> currentPickId = new ConcurrentHashMap<>(); // aucSeq -> pickId

    public AuctionAutoRunner(AuctionService auctionService, SimpMessagingTemplate msg) {
        this.auctionService = auctionService;
        this.msg = msg;
    }

    /** 경매 라운드 자동 진행 시작(이미 진행 중이면 무시) */
    public synchronized void start(Long aucSeq) {
        if (futures.containsKey(aucSeq)) return;

        Map<String,Object> snap = auctionService.findCurrentPickSnapshot(aucSeq);
        if (snap == null) {
            snap = auctionService.initRoundAndBeginFirstPick(aucSeq);
            msg.convertAndSend("/topic/auc."+aucSeq+".state", snap);
        }

        Long pickId = ((Number)snap.get("pickId")).longValue();
        currentPickId.put(aucSeq, pickId);
        schedule(aucSeq, pickId, 7);
    }

    /** 입찰이 들어오면 7초 리셋 */
    public synchronized void reset(Long aucSeq, Long pickId, int seconds) {
        currentPickId.put(aucSeq, pickId);
        cancel(aucSeq);
        schedule(aucSeq, pickId, seconds);
    }

    /** 중지(라운드 종료 등) */
    public synchronized void stop(Long aucSeq) {
        cancel(aucSeq);
        currentPickId.remove(aucSeq);
    }

    @PreDestroy
    public void shutdown() {
        try { exec.shutdownNow(); } catch (Exception ignore) {}
    }

    // ===== 내부 =====

    private void schedule(final Long aucSeq, final Long pickId, final int seconds) {
        final long deadline = System.currentTimeMillis() + seconds * 1000L;

        // 클라이언트 카운트다운 보정용 간단 스냅샷 (pickId / deadlineTs)
        java.util.Map<String,Object> tick = new java.util.HashMap<>();
        tick.put("pickId", pickId);
        tick.put("deadlineTs", deadline);
        msg.convertAndSend("/topic/auc."+aucSeq+".state", tick);

        ScheduledFuture<?> f = exec.schedule(() -> {
            try {
                // 만료 시 픽 마감 → 다음 READY가 있으면 beginPick
                Map<String,Object> out = auctionService.finalizePick(aucSeq, pickId);

                if (out.get("roundEnd") == Boolean.TRUE) {
                    // 라운드 종료
                    java.util.Map<String,Object> end = new java.util.HashMap<>();
                    end.put("roundEnd", true);
                    msg.convertAndSend("/topic/auc."+aucSeq+".state", end);
                    stop(aucSeq);
                    return;
                }

                if (out.get("nextPickId") != null) {
                    Long nextId = ((Number) out.get("nextPickId")).longValue();
                    String nextTarget = String.valueOf(out.get("nextTarget"));
                    long dl = ((Number) out.get("deadlineTs")).longValue();

                    java.util.Map<String,Object> nextSnap = new java.util.HashMap<>();
                    nextSnap.put("pickId", nextId);
                    nextSnap.put("targetNick", nextTarget);
                    nextSnap.put("highestBid", 0);
                    nextSnap.put("deadlineTs", dl);
                    msg.convertAndSend("/topic/auc."+aucSeq+".state", nextSnap);

                    currentPickId.put(aucSeq, nextId);
                    // 다음 픽도 7초 타이머
                    schedule(aucSeq, nextId, 7);
                } else {
                    // 안전망: nextPickId가 없다면 종료 처리
                    java.util.Map<String,Object> end = new java.util.HashMap<>();
                    end.put("roundEnd", true);
                    msg.convertAndSend("/topic/auc."+aucSeq+".state", end);
                    stop(aucSeq);
                }
            } catch (Throwable t) {
                // 예외 시 정리
                stop(aucSeq);
            }
        }, seconds, TimeUnit.SECONDS);

        futures.put(aucSeq, f);
    }

    private void cancel(Long aucSeq) {
        ScheduledFuture<?> f = futures.remove(aucSeq);
        if (f != null) {
            try { f.cancel(false); } catch (Exception ignore) {}
        }
    }
}
