package kr.lolland.dao;

import java.util.List;
import java.util.Map;

public interface AuctionDao {
	Map<String, Object> getAuctionMax(Map<String, Object> seq_params);

	List<Map<String, Object>> getAucTargetListA();
	
	List<Map<String, Object>> getAucTargetListB();
}
