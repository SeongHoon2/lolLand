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

@Component
public class AuctionAutoRunner {

    private final SimpMessagingTemplate msg;
    private final AuctionService auctionService;

    private final ScheduledExecutorService ses = Executors.newScheduledThreadPool(2);
    // aucSeq 별로 현재 진행 중인 타이머를 관리
    private final Map<Long, ScheduledFuture<?>> timers = new ConcurrentHashMap<>();
    // aucSeq → 진행 중 pickId (데드라인 만료 시 동일 pick 이어야만 finalize)
    private final Map<Long, Long> currentPick = new ConcurrentHashMap<>();

    public AuctionAutoRunner(SimpMessagingTemplate msg, AuctionService auctionService) {
        this.msg = msg;
        this.auctionService = auctionService;
    }

    /** 라운드를 시작하거나, 이미 돌고 있으면 무시 */
    public synchronized void start(Long aucSeq) {
        // 현재 진행 중 픽을 확인해서 기록만 함 (없으면 무시)
        Map<String, Object> snap = auctionService.findCurrentPickSnapshot(aucSeq);
        if (snap != null) {
            Long pickId = ((Number) snap.get("pickId")).longValue();
            currentPick.put(aucSeq, pickId);
        }
    }

    /** 입찰이 들어올 때마다 7초로 연장 */
    public synchronized void reset(Long aucSeq, Long pickId, int seconds) {
        // 다른 픽으로 바뀐 경우를 대비해 갱신
        currentPick.put(aucSeq, pickId);

        // 기존 타이머 취소
        ScheduledFuture<?> old = timers.remove(aucSeq);
        if (old != null) old.cancel(false);

        // 새 타이머 예약
        ScheduledFuture<?> f = ses.schedule(() -> onTimeout(aucSeq, pickId), seconds, TimeUnit.SECONDS);
        timers.put(aucSeq, f);
    }

    /** 타임아웃(7초 종료) 시 호출 */
    private void onTimeout(Long aucSeq, Long pickIdAtSchedule) {
        try {
            // 최종적으로 같은 픽에 대해 타임아웃이 발생했는지 확인
            Long cur = currentPick.get(aucSeq);
            if (cur == null || !cur.equals(pickIdAtSchedule)) return;

            // ★ 낙찰/유찰 확정
            Map<String, Object> out = auctionService.finalizePick(aucSeq, pickIdAtSchedule);

            // ★ 반드시 확정 결과를 방송 (assigned / price / teamId / targetNick / teamBudgetLeft / nextPickId …)
            msg.convertAndSend("/topic/auc." + aucSeq + ".state", out);

            // 다음 픽이 열렸다면 currentPick 갱신 및 타이머 재기동
            if (out.get("nextPickId") != null) {
                Long nextPick = ((Number) out.get("nextPickId")).longValue();
                currentPick.put(aucSeq, nextPick);
                // 다음 픽은 오픈과 동시에 7초
                reset(aucSeq, nextPick, 7);
            } else {
                // 라운드 종료
                currentPick.remove(aucSeq);
                ScheduledFuture<?> f = timers.remove(aucSeq);
                if (f != null) f.cancel(false);
            }
        } catch (Exception e) {
            // 실패 로그만 남기고 조용히 종료
            e.printStackTrace();
        }
    }
}
