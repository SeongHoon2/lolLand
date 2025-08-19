package kr.lolland.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.lolland.service.AuctionService;

@Controller
public class AuctionController {

    @Autowired
    private AuctionService auctionService;
    
    @RequestMapping(value = "/getAucTargetAjax", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> getAucTargetAjax() {
        Map<String, Object> result = new HashMap<>();
        try {
            List<Map<String, Object>> listA = auctionService.getAucTargetListA();
            List<Map<String, Object>> listB = auctionService.getAucTargetListB();
            Map<String,Object> dt1 = new HashMap<>();
            Map<String,Object> dt2 = new HashMap<>();
            
            dt1.put("dt", "0000-00-00 00:00:00");
            dt2.put("dt", "0000-00-00 00:00:00");
            
            if(!listA.isEmpty()&&listA!=null) {
            	dt1.put("dt", listA.get(0).get("REG_DT").toString());
            }
           
            if(!listB.isEmpty()&&listB!=null) {
            	dt2.put("dt", listB.get(0).get("REG_DT").toString());
            }
            
            result.put("listA", listA);
            result.put("listB", listB);
            result.put("dt1", dt1);
            result.put("dt2", dt2);
            
        } catch (Exception e) {}
        return result;
    }
}