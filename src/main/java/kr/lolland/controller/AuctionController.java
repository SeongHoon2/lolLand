package kr.lolland.controller;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

import kr.lolland.service.AuctionService;

@Controller
public class AuctionController {

    @Autowired
    private AuctionService auctionService;

}