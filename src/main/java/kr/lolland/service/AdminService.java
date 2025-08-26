package kr.lolland.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.lolland.dao.AdminDao;

@Service
public class AdminService {

    public enum OpenLobbyResult { OK, LIMIT, STALE }

    @Autowired
    private AdminDao adminDao;

    private final Object lobbyLock = new Object();

    public void insertAuctionMain(Map<String, Object> params) { adminDao.insertAuctionMain(params); }
    public void insAuctionMember(Map<String, Object> params) { adminDao.insAuctionMember(params); }

    public Map<String,Object> getAucMainList(String query,int page,int size){
        int p = Math.max(page, 1);
        int s = Math.max(size, 1);
        int offset = (p - 1) * s;
        List<Map<String,Object>> list = adminDao.getAucMainList(query,s,offset);
        int total = adminDao.countAucMainList(query);
        Map<String,Object> res = new HashMap<>();
        res.put("list", list);
        res.put("page", buildPage(p,s,total));
        return res;
    }

    public Map<String,Object> getAucMainData(long id){
        return adminDao.getAucMainData(id);
    }

    public Map<String,Object> getAuctionMembers(long id,int page,int size){
        int p = Math.max(page, 1);
        int s = Math.max(size, 1);
        int offset = (p - 1) * s;
        List<Map<String,Object>> list = adminDao.getAuctionMembers(id,s,offset);
        int total = adminDao.countAuctionMembers(id);
        Map<String,Object> res = new HashMap<>();
        res.put("list", list);
        res.put("page", buildPage(p,s,total));
        return res;
    }

    private Map<String,Object> buildPage(int number,int size,int totalCount){
        int totalPages = (int)Math.ceil((double)totalCount/size);
        Map<String,Object> p = new HashMap<>();
        p.put("number", number);
        p.put("size", size);
        p.put("totalPages", totalPages);
        p.put("totalCount", totalCount);
        return p;
    }

    @Transactional
    public OpenLobbyResult openLobby(long aucId) {
        synchronized (lobbyLock) {
            int active = adminDao.countActiveAuctions();
            if (active >= 2) return OpenLobbyResult.LIMIT;
            int updated = adminDao.updateStatusIfSyncToWait(aucId);
            return (updated == 1) ? OpenLobbyResult.OK : OpenLobbyResult.STALE;
        }
    }

    @Transactional
    public boolean forceEnd(long aucId) {
        return adminDao.updateStatusToEnd(aucId) == 1;
    }
}
