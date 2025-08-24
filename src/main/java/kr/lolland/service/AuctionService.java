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

}
