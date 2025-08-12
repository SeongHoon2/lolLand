package kr.lolland.controller;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import kr.lolland.service.AuctionService;

@Controller
public class AuctionController {

    @Autowired
    private AuctionService auctionService;

    @RequestMapping(value = "/auction", method = RequestMethod.GET)
    public String auction(Model model) {
        List<Map<String, Object>> items = auctionService.listItems();
        model.addAttribute("items", items);
        return "auction";
    }
}