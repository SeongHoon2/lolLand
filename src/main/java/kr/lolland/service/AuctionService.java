package kr.lolland.service;

import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import kr.lolland.dao.AuctionDao;

@Service
public class AuctionService {

    @Autowired
    private AuctionDao auctionDao;

	public Map<String, Object> getAuctionMax(Map<String, Object> seq_params) {
		return auctionDao.getAuctionMax(seq_params);
	}

	public List<Map<String, Object>> getAucTargetListA() {
		return auctionDao.getAucTargetListA();
	}
	
	public List<Map<String, Object>> getAucTargetListB() {
		return auctionDao.getAucTargetListB();
	}
}
