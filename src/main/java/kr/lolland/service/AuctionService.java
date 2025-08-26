package kr.lolland.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.lolland.dao.AuctionDao;

@Service
public class AuctionService {

    private final AuctionDao auctionDao;

    public AuctionService(AuctionDao auctionDao) {
        this.auctionDao = auctionDao;
    }

    public Map<String, Object> getAucByRandomCode(String randomCode){
        return auctionDao.selectAucMainByRandomCode(randomCode);
    }

    public boolean existsLeaderNick(Long aucSeq, String nick){
        Integer cnt = auctionDao.countLeaderByNick(aucSeq, nick);
        return cnt != null && cnt > 0;
    }

    @Transactional
    public void markLeaderOnline(Long aucSeq, String nick, String onlineYn){
        auctionDao.updateLeaderOnline(aucSeq, nick, onlineYn);
    }

    public Map<String, Object> getLobbySnapshot(Long aucSeq){
        Map<String, Object> r = new HashMap<>();

        // 리더 목록
        List<Map<String,Object>> leaders = auctionDao.selectLeaders(aucSeq);
        r.put("leaders", leaders);

        // 집계
        int leaderCnt = (leaders != null) ? leaders.size() : 0;   // 전체 리더 수
        int readyCnt  = 0;                                        // READY_YN='Y' 수
        int onlineCnt = 0;                                        // ONLINE_YN='Y' 수 (참고용)

        if (leaders != null) {
            for (Map<String,Object> m : leaders) {
                String ready  = String.valueOf(m.get("READY_YN"));
                String online = String.valueOf(m.get("ONLINE_YN"));
                if ("Y".equalsIgnoreCase(ready))  readyCnt++;
                if ("Y".equalsIgnoreCase(online)) onlineCnt++;
            }
        }

        // 스냅샷 필드 채우기 (프론트가 이 키들을 씀)
        r.put("leaderCnt", leaderCnt);
        r.put("readyCnt",  readyCnt);
        r.put("onlineCnt", onlineCnt); // 필요 없으면 제거해도 됨

        // 기존 유지
        r.put("viewers", new Object[0]);
        r.put("viewerCnt", 0);

        return r;
    }


    @Transactional
    public void toggleReady(Long aucSeq, String nick){
        auctionDao.toggleReady(aucSeq, nick);
    }

    public int countActiveAuctions(){
        return auctionDao.countActiveAuctions();
    }

    @Transactional
    public void startAuction(Long aucSeq){
        auctionDao.updateAucStatus(aucSeq, "ING");
    }
    
    @Transactional
    public void markLeaderReady(Long aucSeq, String nick, String yn){
        auctionDao.markLeaderReady(aucSeq, nick, yn);
    }
    
    @Transactional
    public void setLeaderReady(Long aucSeq, String nick, String readyYn) {
        auctionDao.setLeaderReady(aucSeq, nick, readyYn);
    }
}
