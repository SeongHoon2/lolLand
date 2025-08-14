package kr.lolland.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class PageController {
	
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String index(Model model) {
		//return "redirect:/auction";
		return "auction";
	}

    @RequestMapping(value = "/auction", method = RequestMethod.GET)
    public String auction(Model model) {
        return "auction";
    }
}