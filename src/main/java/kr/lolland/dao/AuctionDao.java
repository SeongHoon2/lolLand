package kr.lolland.dao;

import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface AuctionDao {

    Map<String, Object> selectAucMainByRandomCode(@Param("code") String randomCode);

    Integer countLeaderByNick(@Param("aucSeq") Long aucSeq, @Param("nick") String nick);

    int updateLeaderOnline(@Param("aucSeq") Long aucSeq, @Param("nick") String nick, @Param("onlineYn") String onlineYn);

    List<Map<String, Object>> selectLeaders(@Param("aucSeq") Long aucSeq);

    int toggleReady(@Param("aucSeq") Long aucSeq, @Param("nick") String nick);

    int countActiveAuctions();

    int updateAucStatus(@Param("aucSeq") Long aucSeq, @Param("status") String status);
    
    int markLeaderReady(@Param("aucSeq") Long aucSeq, @Param("nick") String nick, @Param("readyYn") String readyYn);
    
    int setLeaderReady(@Param("aucSeq") Long aucSeq, @Param("nick") String nick, @Param("readyYn") String readyYn);
}
