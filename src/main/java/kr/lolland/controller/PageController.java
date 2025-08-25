package kr.lolland.controller;

import java.util.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import kr.lolland.controller.PageController;


import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.http.ResponseEntity;

@Controller
public class PageController {
	
	private static final String ADMIN_AUTH = "ADMIN_AUTH";
	private static final String ADMIN_SERIAL_KEY = System.getenv().getOrDefault("ADMIN_SERIAL_KEY", "tjdgns");
	
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String index(Model model) {
		return "redirect:/auction";
	}

    @RequestMapping(value = "/auction", method = RequestMethod.GET)
    public String auction(Model model, HttpSession session) {
        return "auction";
    }

    @GetMapping({"/createAuction", "/manageAuction"})
    public Object adminPages(HttpSession session, HttpServletRequest req, Model model) {
        if (isAdmin(session)) {
            String uri = req.getRequestURI();
            if (uri.endsWith("createAuction")) return "createAuction";
            if (uri.endsWith("manageAuction")) return "manageAuction";
        }
        return ResponseEntity.ok().header("Content-Type", "text/html; charset=UTF-8").body(buildChallengeHtml(req, req.getRequestURI()));
    }

    private String buildChallengeHtml(HttpServletRequest req, String targetUrl) {
        String ctx = req.getContextPath();
        String safeTarget = (targetUrl != null && targetUrl.startsWith(ctx)) ? targetUrl : (ctx + "/auction");
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'>"
                + "<meta http-equiv='Cache-Control' content='no-store'/>"
                + "<title>lolLand</title></head><body>"
                + "<script>(function(){\n"
                + "  var key = prompt('관리자 코드를 입력하세요:');\n"
                + "  if(!key){location.replace('" + ctx + "/auction');return;}\n"
                + "  fetch('" + ctx + "/admin/auth', {\n"
                + "    method: 'POST',\n"
                + "    headers: {'Content-Type':'application/x-www-form-urlencoded','X-Requested-With':'XMLHttpRequest'},\n"
                + "    body: 'serialKey=' + encodeURIComponent(key)\n"
                + "  }).then(function(r){return r.json();}).then(function(res){\n"
                + "    if(res && res.ok){ location.replace('" + safeTarget + "'); }\n"
                + "    else { alert((res&&res.message)?res.message:'인증 실패'); location.replace('" + ctx + "/auction'); }\n"
                + "  }).catch(function(){ alert('서버 오류'); location.replace('" + ctx + "/auction'); });\n"
                + "})();</script></body></html>";
    }

    @PostMapping("/admin/auth")
    @ResponseBody
    public Map<String,Object> auth(@RequestParam("serialKey") String serialKey, HttpSession session) {
        Map<String,Object> res = new HashMap<>();
        if (ADMIN_SERIAL_KEY.equals(serialKey)) {
            session.setAttribute(ADMIN_AUTH, Boolean.TRUE);
            session.setMaxInactiveInterval(1800);
            res.put("ok", true);
        } else {
            res.put("ok", false);
            res.put("message", "잘못된 관리자 코드입니다.");
        }
        return res;
    }

    private boolean isAdmin(HttpSession session) {
        return session != null && Boolean.TRUE.equals(session.getAttribute(ADMIN_AUTH));
    }

}