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
    
    List<Map<String, Object>> selectNonLeaderPlayers(@Param("aucSeq") Long aucSeq);

    int insertMissingTeamsFromLeaders(@Param("aucSeq") Long aucSeq);

    List<Map<String, Object>> selectTeamsByAuc(@Param("aucSeq") Long aucSeq);

    Map<String,Object> selectLatestEventByType(@Param("aucSeq") Long aucSeq, @Param("type") String type);
    
    int insertEvent(@Param("aucSeq") Long aucSeq, @Param("type") String type, @Param("payload") String payloadJson);

    List<Map<String,Object>> selectLeaderDetails(@Param("aucSeq") Long aucSeq);
    
    int insertRound(@Param("aucSeq") Long aucSeq, @Param("roundNo") int roundNo);
    
    Map<String,Object> selectRoundByNo(@Param("aucSeq") Long aucSeq, @Param("roundNo") int roundNo);
    
    int updateRoundStatus(@Param("roundId") Long roundId, @Param("status") String status);
    
    List<Map<String,Object>> selectPlayersForPick(@Param("aucSeq") Long aucSeq);
    
    int insertPick(@Param("roundId") Long roundId, @Param("aucSeq") Long aucSeq,@Param("pickNo") int pickNo, @Param("targetNick") String nick);

    Map<String,Object> selectNextReadyPick(@Param("aucSeq") Long aucSeq);
    
    int beginPick(@Param("pickId") Long pickId);
    
    Map<String,Object> selectPickById(@Param("pickId") Long pickId);

    Map<String,Object> selectTeamById(@Param("teamId") Long teamId);

    int insertBid(@Param("aucSeq") Long aucSeq, @Param("pickId") Long pickId,@Param("teamId") Long teamId, @Param("nick") String nick,@Param("amount") int amount, @Param("allin") String allin);

    int updatePickHighest(@Param("pickId") Long pickId, @Param("amount") int amount,@Param("teamId") Long teamId, @Param("version") int version);

    int skipPick(@Param("pickId") Long pickId);
    
    int incrementSkip(@Param("pickId") Long pickId);
    
    int assignPick(@Param("pickId") Long pickId);

    int updateTeamBudget(@Param("teamId") Long teamId, @Param("delta") int delta);
    
    int insertTeamMember(@Param("teamId") Long teamId, @Param("aucSeq") Long aucSeq,@Param("nick") String nick, @Param("price") int price, @Param("pickId") Long pickId);

    Map<String,Object> selectMaxPickNo(@Param("roundId") Long roundId);
    
    int appendRequeuedPick(@Param("roundId") Long roundId, @Param("aucSeq") Long aucSeq,@Param("targetNick") String targetNick, @Param("nextNo") int nextNo);

	Map<String, Object> selectCurrentBiddingPick(Long aucSeq);

	Long findTeamIdByLeader(@Param("aucSeq") Long aucSeq, @Param("nick")   String nick);

    Map<String,Object> selectMemberByNick(@Param("aucSeq") Long aucSeq, @Param("nick") String nick);
    
    List<Map<String,Object>> selectTeamMembersByAuc(@Param("aucSeq") Long aucSeq);
    
    int countTeamMembersByTeam(@Param("teamId") Long teamId);

    int countAnyMemberByNick(@Param("aucSeq") Long aucSeq, @Param("nick") String nick);
    
    String selectAllinYnByPickAndAmount(@Param("pickId") Long pickId, @Param("amount") int amount);

}
