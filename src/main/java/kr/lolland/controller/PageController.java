package kr.lolland.controller;

import java.util.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import kr.lolland.controller.PageController;
import kr.lolland.service.CommonService;
import kr.lolland.service.AuctionService;

import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.sheets.v4.Sheets;
import com.google.api.services.sheets.v4.model.ValueRange;
import com.google.api.services.sheets.v4.SheetsScopes;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.http.HttpCredentialsAdapter;
import java.io.FileInputStream;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;

@Controller
public class PageController {
	
	private static final String ADMIN_AUTH = "ADMIN_AUTH";
	private static final String ADMIN_SERIAL_KEY = System.getenv().getOrDefault("ADMIN_SERIAL_KEY", "lolLand1!2@");

	@Autowired
	private CommonService commonService;
	
	@Autowired
	private AuctionService auctionService;
	
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String index(Model model) {
		return "redirect:/auction";
		//return "auction";
	}

    @RequestMapping(value = "/auction", method = RequestMethod.GET)
    public String auction(Model model) {
        return "auction";
    }
    
    @GetMapping("/admin")
    public Object admin(HttpSession session, HttpServletRequest req, Model model) {
        if (isAdmin(session)) {
            return "admin";
        }
        return ResponseEntity.ok().header("Content-Type", "text/html; charset=UTF-8").body(buildChallengeHtml(req));
    }

    private String buildChallengeHtml(HttpServletRequest req) {
        String ctx = req.getContextPath();
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'>" +
               "<meta http-equiv='Cache-Control' content='no-store'/>" +
               "<title>lolLand</title></head><body>" +
               "<script>(function(){\n" +
               "  var key = prompt('관리자 코드를 입력하세요:');\n" +
               "  if(!key){location.replace('" + ctx + "/auction');return;}\n" +
               "  fetch('" + ctx + "/admin/auth', {\n" +
               "    method: 'POST',\n" +
               "    headers: {'Content-Type':'application/x-www-form-urlencoded','X-Requested-With':'XMLHttpRequest'},\n" +
               "    body: 'serialKey=' + encodeURIComponent(key)\n" +
               "  }).then(function(r){return r.json();}).then(function(res){\n" +
               "    if(res && res.ok){ location.replace('" + ctx + "/admin'); }\n" +
               "    else { alert((res&&res.message)?res.message:'인증 실패'); location.replace('" + ctx + "/auction'); }\n" +
               "  }).catch(function(){ alert('서버 오류'); location.replace('" + ctx + "/auction'); });\n" +
               "})();</script></body></html>";
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

    @RequestMapping(value = "/updAuctionMember", method = RequestMethod.POST)
    public Map<String, Object> updMember(Model model, @RequestParam ("groupCd") String groupCd) {
    	Map<String, Object> result = new HashMap<>();
    	try {
    		String keyPath;
    		String osName = System.getProperty("os.name").toLowerCase();
    		if (osName.contains("win")) {
    			//keyPath = "C:/Users/SH/Downloads/test/lolLandKey.json"; // home
    			keyPath = "C:/Users/User/Desktop/test/lolLandKey.json"; // work
    		} else {
    			keyPath = "/opt/etc/keys/lolLandKey.json";
    		}
    		
    		NetHttpTransport httpTransport = GoogleNetHttpTransport.newTrustedTransport();
    		JsonFactory jsonFactory = GsonFactory.getDefaultInstance();
    		GoogleCredentials credentials = GoogleCredentials.fromStream(new FileInputStream(keyPath)).createScoped(Collections.singletonList(SheetsScopes.SPREADSHEETS));
    		Sheets service = new Sheets.Builder(httpTransport, jsonFactory,new HttpCredentialsAdapter(credentials)).setApplicationName("LolLand Auction System").build();
    		
    		String spreadsheetId = "1P-I6ZnQbkjaJ2yl7zaGnv8A4t9luP3fQLFnRDuD4wQE";
    		String range = "";
    		if(groupCd.equals("1")) {
    			range = "Auction!B5:G44";
    		}
    		else {
    			range = "Auction!I5:N44";
    		}
    		
    		ValueRange response = service.spreadsheets().values().get(spreadsheetId, range).execute();
    		List<List<Object>> values = response.getValues();
    		List<Map<String, Object>> members = new ArrayList<Map<String, Object>>();
    		
    		Map<String, Object> seq_params = new HashMap<>();
    		seq_params.put("seq_params",groupCd);
    		
    		Map<String, Object> aucSeq = auctionService.getAuctionMax(seq_params);
    		
    		for (List<Object> row : values) {
    		    Map<String, Object> m = new HashMap<>();
    		    m.put("AUC_CD",    groupCd);  
    		    m.put("AUC_SEQ",   aucSeq.get("MAX_CNT").toString());
    		    m.put("NO",        row.size() > 0 ? row.get(0) : "");
    		    m.put("NICK",      row.size() > 1 ? row.get(1) : "");
    		    m.put("TIER",      row.size() > 2 ? row.get(2) : "");
    		    m.put("MROLE",     row.size() > 3 ? row.get(3) : "");
    		    m.put("SROLE",     row.size() > 4 ? row.get(4) : "");
    		    m.put("LEADERFLG", row.size() > 5 ? "Y" : "N");
    		    members.add(m);
    		}
    		
    		commonService.updAuctionStatus(seq_params);
    		
    		String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            StringBuilder sb = new StringBuilder();
            Random rand = new Random();

            for (int i = 0; i < 8; i++) {
                int index = rand.nextInt(chars.length());
                sb.append(chars.charAt(index));
            }

            String randomCode = sb.toString();
    		
    		for (Map<String, Object> row : members) {
    			if(!row.get("NO").toString().equals("")    &&
    			   !row.get("NICK").toString().equals("")  &&
    			   !row.get("TIER").toString().equals("")  &&
    			   !row.get("MROLE").toString().equals("")) 
    			{
    				Map<String, Object> params = new HashMap<>();
    				params.put("AUC_CD",    row.get("AUC_CD").toString());
    				params.put("AUC_SEQ",   row.get("AUC_SEQ").toString());
    				params.put("NO",        row.get("NO").toString());
    				params.put("NICK",      row.get("NICK").toString());
    				params.put("TIER",      row.get("TIER").toString());
    				params.put("MROLE",     row.get("MROLE").toString());
    				params.put("SROLE",     row.get("SROLE").toString());
    				params.put("LEADERFLG", row.get("LEADERFLG").toString());
    				params.put("RANDOMCODE",randomCode);
    				commonService.insAuctionMember(params);
    			}
    		}
    	} catch (Exception e) {}
    	
    	return result;
    }
}