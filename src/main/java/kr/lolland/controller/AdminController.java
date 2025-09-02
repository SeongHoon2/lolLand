package kr.lolland.controller;

import java.io.FileInputStream;
import java.security.SecureRandom;
import java.text.Collator;
import java.util.*;
import java.util.Locale;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.sheets.v4.Sheets;
import com.google.api.services.sheets.v4.SheetsScopes;
import com.google.api.services.sheets.v4.model.ValueRange;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.GoogleCredentials;

import kr.lolland.service.AdminService;

@Controller
public class AdminController {

    @Autowired
    private AdminService adminService;

    @PostMapping("/syncAuctionMembers")
    @ResponseBody
    public Map<String,Object> syncAuctionMembers() {
        Map<String,Object> res = new HashMap<>();
        try {
            String keyPath;
            String osName = System.getProperty("os.name").toLowerCase();  
            if (osName.contains("win")) {
            	//keyPath = "C:/Users/SH/Downloads/test/lolLandKey.json";  // main
            	//keyPath = "C:/Users/znfmf/Downloads/test/lolLandKey.json"; // sub
            	keyPath = "C:/Users/User/Desktop/test/lolLandKey.json"; // work
            } else {
                keyPath = "/opt/etc/keys/lolLandKey.json"; 
            }
            NetHttpTransport httpTransport = GoogleNetHttpTransport.newTrustedTransport();
            JsonFactory jsonFactory = GsonFactory.getDefaultInstance();
            GoogleCredentials credentials = GoogleCredentials.fromStream(new FileInputStream(keyPath)).createScoped(Collections.singletonList(SheetsScopes.SPREADSHEETS));
            Sheets service = new Sheets.Builder(httpTransport, jsonFactory, new HttpCredentialsAdapter(credentials)).setApplicationName("LolLand Auction System").build();
 
            String spreadsheetId = "1P-I6ZnQbkjaJ2yl7zaGnv8A4t9luP3fQLFnRDuD4wQE";
            String range = "Auction!B3:G42";
            ValueRange response = service.spreadsheets().values().get(spreadsheetId, range).execute();
            List<List<Object>> values = response.getValues(); 

            List<Map<String,Object>> members = new ArrayList<>();
            if (values != null) {
                for (List<Object> row : values) {
                    if (row == null || row.isEmpty()) continue;
                    Map<String,Object> m = new HashMap<>();
                    m.put("NO",        row.size()>0 ? String.valueOf(row.get(0)) : "");
                    m.put("NICK",      row.size()>1 ? String.valueOf(row.get(1)) : "");
                    m.put("TIER",      row.size()>2 ? String.valueOf(row.get(2)) : "");
                    m.put("MROLE",     row.size()>3 ? String.valueOf(row.get(3)) : "");
                    m.put("SROLE",     row.size()>4 ? String.valueOf(row.get(4)) : "");
                    m.put("POINT", "");
                    String leaderRaw  = row.size()>5 ? String.valueOf(row.get(5)) : "";
                    m.put("LEADERFLG", "Y".equalsIgnoreCase(leaderRaw) ? "Y" : "N");
                    if (!String.valueOf(m.get("NO")).isEmpty()
                            && !String.valueOf(m.get("NICK")).isEmpty()
                            && !String.valueOf(m.get("TIER")).isEmpty()
                            && !String.valueOf(m.get("MROLE")).isEmpty()) {
                        members.add(m);
                    }
                }
            }

            Map<String, Integer> tierOrder = new HashMap<>();
            tierOrder.put("C", 1);
            tierOrder.put("GM", 2);
            tierOrder.put("M", 3);
            tierOrder.put("D", 4);
            tierOrder.put("E", 5);
            tierOrder.put("P", 6);
            tierOrder.put("G", 7);
            tierOrder.put("S", 8);
            tierOrder.put("B", 9);
            tierOrder.put("I", 10);

            Collator coll = Collator.getInstance(Locale.KOREAN);
            coll.setStrength(Collator.PRIMARY);

            members.sort((a, b) -> {
                String la = String.valueOf(a.getOrDefault("LEADERFLG","N"));
                String lb = String.valueOf(b.getOrDefault("LEADERFLG","N"));
                if (!la.equals(lb)) {
                    return "Y".equals(lb) ? 1 : -1;
                }

                String ta = String.valueOf(a.getOrDefault("TIER","Z"));
                String tb = String.valueOf(b.getOrDefault("TIER","Z"));
                int ra = tierOrder.getOrDefault(ta, Integer.MAX_VALUE);
                int rb = tierOrder.getOrDefault(tb, Integer.MAX_VALUE);
                if (ra != rb) {
                    return Integer.compare(ra, rb);
                }

                String na = String.valueOf(a.getOrDefault("NICK",""));
                String nb = String.valueOf(b.getOrDefault("NICK",""));
                return coll.compare(na, nb);
            });

            for (int i = 0; i < members.size(); i++) {
                Object org = members.get(i).get("NO");
                members.get(i).put("ORG_NO", org == null ? "" : String.valueOf(org));
                members.get(i).put("NO", String.valueOf(i + 1));
            }

            res.put("status", true);
            res.put("members", members);
            res.put("syncedAt", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));
        } catch (Exception e) {
            res.put("status", false);
        }
        return res;
    }

    @PostMapping("/saveAuctionMembers")
    @ResponseBody
    public Map<String,Object> saveAuctionMembers(@RequestBody Map<String,Object> body) {
        Map<String,Object> res = new HashMap<>();
        try {
            @SuppressWarnings("unchecked")
            List<Map<String,Object>> members = (List<Map<String,Object>>) body.getOrDefault("members", Collections.emptyList());

            String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            SecureRandom rand = new SecureRandom();
            StringBuilder sb = new StringBuilder(8);
            for (int i = 0; i < 8; i++) sb.append(chars.charAt(rand.nextInt(chars.length())));
            String randomCode = sb.toString();
            body.put("randomCode", randomCode);

            adminService.insertAuctionMain(body);

            Object seq = body.get("SEQ");
            String aucSeqStr = String.valueOf(seq);

            for (Map<String,Object> row : members) {
                Map<String,Object> params = new HashMap<>();
                params.put("AUC_SEQ",   aucSeqStr);
                params.put("NO",        String.valueOf(row.getOrDefault("NO","")));
                params.put("NICK",      String.valueOf(row.getOrDefault("NICK","")));
                params.put("TIER",      String.valueOf(row.getOrDefault("TIER","")));
                params.put("MROLE",     String.valueOf(row.getOrDefault("MROLE","")));
                params.put("SROLE",     String.valueOf(row.getOrDefault("SROLE","")));
                params.put("LEADERFLG", String.valueOf(row.getOrDefault("LEADERFLG","N")));

                String leader = String.valueOf(row.getOrDefault("LEADERFLG","N"));
                String p = "Y".equalsIgnoreCase(leader) ? String.valueOf(row.getOrDefault("POINT","1000")) : "0";
                if (p == null || !p.matches("^-?\\d+$")) p = "1000";
                params.put("POINT", p);

                if (!params.get("NO").toString().isEmpty()
                        && !params.get("NICK").toString().isEmpty()
                        && !params.get("TIER").toString().isEmpty()
                        && !params.get("MROLE").toString().isEmpty()) {
                    adminService.insAuctionMember(params);
                }
            }
            res.put("ok", true);
        } catch (Exception e) {
            res.put("ok", false);
        }
        return res;
    }

    @GetMapping("/getAucMainList")
    @ResponseBody
    public Map<String,Object> getAucMainList(@RequestParam(defaultValue="") String query,@RequestParam(defaultValue="1") int page,@RequestParam(defaultValue="10") int size) {
        return adminService.getAucMainList(query, page, size);
    }

    @GetMapping("/getAucMainData/{id}")
    @ResponseBody
    public Map<String,Object> getAucMainData(@PathVariable long id){
        return adminService.getAucMainData(id);
    }

    @GetMapping("/getAuctionMembers/{id}")
    @ResponseBody
    public Map<String,Object> getAuctionMembers(@PathVariable long id,@RequestParam(defaultValue="1") int page,@RequestParam(defaultValue="10") int size){
        return adminService.getAuctionMembers(id, page, size);
    }
    
    @PostMapping("/openLobby/{id}")
    @ResponseBody
    public Map<String,Object> openLobby(@PathVariable long id){
        Map<String,Object> res = new HashMap<>();
        try {
            AdminService.OpenLobbyResult r = adminService.openLobby(id);
            switch (r){
                case OK:
                    res.put("ok", true);
                    break;
                case LIMIT:
                    res.put("ok", false);
                    res.put("msg", "로비 오픈 / 진행중인 경매가 이미 2건입니다.");
                    break;
                case STALE:
                    res.put("ok", false);
                    res.put("msg", "상태가 이미 변경되어 로비 오픈할 수 없습니다.");
                    break;
                default:
                    res.put("ok", false);
                    res.put("msg", "로비 오픈에 실패했습니다.");
            }
        } catch (Exception e){
            res.put("ok", false);
            res.put("msg", "서버 오류로 로비 오픈에 실패했습니다.");
        }
        return res;
    }

    @PostMapping("/forceEnd/{id}")
    @ResponseBody
    public Map<String,Object> forceEnd(@PathVariable long id){
        Map<String,Object> res = new HashMap<>();
        try {
            boolean ok = adminService.forceEnd(id);
            res.put("ok", ok);
            if (!ok) res.put("msg", "강제 종료 대상이 없거나 상태가 유효하지 않습니다.");
        } catch (Exception e){
            res.put("ok", false);
            res.put("msg", "서버 오류로 강제 종료에 실패했습니다.");
        }
        return res;
    }

}
