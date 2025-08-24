package kr.lolland.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.lolland.dao.AdminDao;

@Service
public class AdminService {

    @Autowired
    private AdminDao adminDao;

	public void insertAuctionMain(Map<String, Object> params) {
		adminDao.insertAuctionMain(params);
	}
	
	public void insAuctionMember(Map<String, Object> params) {
		adminDao.insAuctionMember(params);
	}

	public Map<String,Object> getAucMainList(String query,int page,int size){
	    int offset=(page-1)*size;
	    List<Map<String,Object>> list=adminDao.getAucMainList(query,size,offset);
	    int total=adminDao.countAucMainList(query);
	    Map<String,Object> res=new HashMap<>();
	    res.put("list",list);
	    res.put("page",buildPage(page,size,total));
	    return res;
	}

	public Map<String,Object> getAucMainData(long id){
	    return adminDao.getAucMainData(id);
	}

	public Map<String,Object> getAuctionMembers(long id,int page,int size){
	    int offset=(page-1)*size;
	    List<Map<String,Object>> list=adminDao.getAuctionMembers(id,size,offset);
	    int total=adminDao.countAuctionMembers(id);
	    Map<String,Object> res=new HashMap<>();
	    res.put("list",list);
	    res.put("page",buildPage(page,size,total));
	    return res;
	}

	private Map<String,Object> buildPage(int number,int size,int totalCount){
	    int totalPages=(int)Math.ceil((double)totalCount/size);
	    Map<String,Object> p=new HashMap<>();
	    p.put("number",number);
	    p.put("size",size);
	    p.put("totalPages",totalPages);
	    p.put("totalCount",totalCount);
	    return p;
	}

}