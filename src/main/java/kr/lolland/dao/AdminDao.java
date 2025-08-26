package kr.lolland.dao;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface AdminDao {

    void insertAuctionMain(Map<String, Object> params);

    void insAuctionMember(Map<String, Object> params);

    List<Map<String,Object>> getAucMainList(@Param("query") String query,@Param("size") int size,@Param("offset") int offset);

    int countAucMainList(@Param("query") String query);

    Map<String,Object> getAucMainData(@Param("id") long id);

    List<Map<String,Object>> getAuctionMembers(@Param("id") long id,@Param("size") int size,@Param("offset") int offset);

    int countAuctionMembers(@Param("id") long id);

    int countActiveAuctions();
    
    int updateStatusIfSyncToWait(long id);
    
    int updateStatusToEnd(long id);
}