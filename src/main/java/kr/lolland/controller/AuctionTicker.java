package kr.lolland.controller;

import java.util.Map;
import java.util.concurrent.*;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import kr.lolland.service.AuctionService;

@Component
public class AuctionTicker {

    private final AuctionService auctionService;
    private final SimpMessagingTemplate msg;

    // 라운드별 단일 타이머만 관리 (경매 하나당 하나)
    private final ScheduledExecutorService exec =
            Executors.newSingleThreadScheduledExecutor(r -> {
                Thread t = new Thread(r, "auction-ticker");
                t.setDaemon(true);
                return t;
            });

    private final Map<Long, ScheduledFuture<?>> jobs = new ConcurrentHashMap<>();

    public AuctionTicker(AuctionService auctionService, SimpMessagingTemplate msg) {
        this.auctionService = auctionService;
        this.msg = msg;
    }

    /** 절대시각(deadlineTs, epoch ms) 기준으로 타이머 (재)설정 */
    public void startOrReset(Long aucSeq, Long pickId, long deadlineTs){
        long delay = Math.max(0, deadlineTs - System.currentTimeMillis());
        cancel(aucSeq); // 기존 타이머 제거 (경매당 1개)
        ScheduledFuture<?> f = exec.schedule(() -> onTimeout(aucSeq, pickId), delay, TimeUnit.MILLISECONDS);
        jobs.put(aucSeq, f);
    }

    /** 경매 종료 등으로 타이머 제거 */
    public void cancel(Long aucSeq){
        ScheduledFuture<?> f = jobs.remove(aucSeq);
        if (f != null) f.cancel(false);
    }

    /** 타임아웃 시 호출: 현재 픽 확정 → 다음 READY 픽 오픈/방송 → 다음 타이머 */
    private void onTimeout(Long aucSeq, Long pickId){
        try {
            // 여전히 같은 픽이 진행 중인지 확인 (경합 방지)
            Map<String,Object> current = auctionService.findCurrentPickSnapshot(aucSeq);
            if (current == null || !String.valueOf(current.get("pickId")).equals(String.valueOf(pickId))) {
                // 이미 다른 픽으로 넘어갔거나 종료됨 → 타이머 불필요
                return;
            }

            // 현재 픽 확정 (무입찰이면 유찰/재배치/0포 처리 포함)
            Map<String,Object> out = auctionService.finalizePick(aucSeq, pickId);

            // 다음 픽이 열렸다면 상태 방송 및 타이머 재무장
            if (out.get("nextPickId") != null) {
                Map<String,Object> next = new java.util.HashMap<>();
                next.put("pickId", out.get("nextPickId"));
                next.put("targetNick", out.get("nextTarget"));
                next.put("highestBid", 0);
                next.put("deadlineTs", out.get("deadlineTs"));
                msg.convertAndSend("/topic/auc."+aucSeq+".state", next);

                // 다음 7초 타이머
                startOrReset(aucSeq,
                        ((Number)out.get("nextPickId")).longValue(),
                        ((Number)out.get("deadlineTs")).longValue());
            } else {
                // 라운드가 끝났다면 타이머 정리
                cancel(aucSeq);
                Map<String,Object> done = new java.util.HashMap<>();
                done.put("roundEnd", true);
                msg.convertAndSend("/topic/auc."+aucSeq+".state", done);
            }
        } catch (Exception e){
            // 에러는 로깅만 (원한다면 로그로 남기기)
            // e.printStackTrace();
            cancel(aucSeq);
        }
    }
}
