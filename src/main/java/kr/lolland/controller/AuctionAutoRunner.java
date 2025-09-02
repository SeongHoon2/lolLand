package kr.lolland.controller;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import kr.lolland.service.AuctionService;

/**
 * 경매 진행용 서버 타이머 러너 (경매당 1개 타이머)
 * - 컨트롤러에서 /begin 시 start(...)
 * - 입찰 성공 시 reset(..., pickId, 7) 로 연장
 * - 타임아웃 시 finalizePick(...) → 다음 픽이 있으면 재스케줄, 없으면 라운드 종료
 *
 * 주의:
 * - reset의 두 번째 인자는 반드시 "현재 진행 중인 pickId(Long)" 입니다.
 * - 다음 픽이 열렸을 때도 "다음 픽의 pickId(Long)"로 갱신 후 재스케줄합니다.
 */
@Component
public class AuctionAutoRunner {

    private final SimpMessagingTemplate msg;
    private final AuctionService auctionService;

    // 경매별 현재 타이머
    private final ScheduledExecutorService exec = Executors.newSingleThreadScheduledExecutor();
    private final Map<Long, ScheduledFuture<?>> timers = new ConcurrentHashMap<>();
    // 경매별 현재 진행 중 pickId
    private final Map<Long, Long> currentPick = new ConcurrentHashMap<>();

    public AuctionAutoRunner(SimpMessagingTemplate msg, AuctionService auctionService) {
        this.msg = msg;
        this.auctionService = auctionService;
    }

    public synchronized void start(Long aucSeq) {
        try {
            Map<String, Object> snap = auctionService.findCurrentPickSnapshot(aucSeq);
            if (snap == null) { cancel(aucSeq); return; }
            Long pickId = toLong(snap.get("pickId"));
            if (pickId == null) { cancel(aucSeq); return; }
            currentPick.put(aucSeq, pickId);

            long deadlineTs = toLong(snap.get("deadlineTs")) != null
                    ? toLong(snap.get("deadlineTs"))
                    : System.currentTimeMillis() + 10000L; // 10초
            scheduleAt(aucSeq, deadlineTs);
        } catch (Exception e) {
            cancel(aucSeq);
        }
    }

    public synchronized void reset(Long aucSeq, Long pickId, int seconds) {
        try {
            cancel(aucSeq);
            if (pickId == null) return;
            currentPick.put(aucSeq, pickId);
            long deadlineTs = System.currentTimeMillis() + Math.max(0, seconds) * 1000L;
            scheduleAt(aucSeq, deadlineTs);
        } catch (Exception e) {
            cancel(aucSeq);
        }
    }

    /** 경매 타이머 취소 */
    public synchronized void cancel(Long aucSeq) {
        ScheduledFuture<?> f = timers.remove(aucSeq);
        if (f != null) {
            try { f.cancel(false); } catch (Exception ignore) {}
        }
    }

    private synchronized void scheduleAt(Long aucSeq, long deadlineTs) {
        long delayMs = Math.max(0L, deadlineTs - System.currentTimeMillis());
        ScheduledFuture<?> f = exec.schedule(() -> onTimeout(aucSeq), delayMs, TimeUnit.MILLISECONDS);
        timers.put(aucSeq, f);
    }

    private void onTimeout(Long aucSeq) {
        try {
            Long pickId = currentPick.get(aucSeq);
            if (pickId == null) { cancel(aucSeq); return; }

            Map<String, Object> out = auctionService.finalizePick(aucSeq, pickId);
            msg.convertAndSend("/topic/auc." + aucSeq + ".state", out);

            Long nextPickId = toLong(out.get("nextPickId")); // 대기중 신호만 제공
            if (nextPickId != null) {
                // 자동 시작 제거: 타이머 종료 상태로 대기
                currentPick.remove(aucSeq);
                cancel(aucSeq);
            } else {
                // 라운드 종료
                currentPick.remove(aucSeq);
                cancel(aucSeq);
                Map<String, Object> done = new java.util.HashMap<>();
                done.put("roundEnd", true);
                msg.convertAndSend("/topic/auc." + aucSeq + ".state", done);
            }
        } catch (Exception e) {
            cancel(aucSeq);
        }
    }

    private static Long toLong(Object o) {
        if (o == null) return null;
        if (o instanceof Long) return (Long) o;
        if (o instanceof Integer) return ((Integer) o).longValue();
        if (o instanceof Number) return ((Number) o).longValue();
        try { return Long.parseLong(String.valueOf(o)); } catch (Exception ignore) { return null; }
    }
}
