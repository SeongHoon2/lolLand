<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<div class="container">
<div class="admin_title">
  <div class="cluster cluster-left">
    <span id="dt1Txt"></span>
    <button name="1" class="admin_updBtn">연동</button>
  </div>
  <div class="cluster cluster-right">
    <span id="dt2Txt"></span>
    <button name="2" class="admin_updBtn">연동</button>
  </div>
</div>

<div class="admin_body">
  <div class="group-box" id="group1"></div>
  <div class="group-box" id="group2"></div>
</div>
</div>
<div id="loading-overlay" class="loading-overlay" style="display:none;">
  <div class="spinner"></div>
  <div style="margin-top:10px;">연동중입니다.</div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
<link rel="stylesheet" href="<c:url value='/resources/css/admin.css'/>">

<script>
$(document).ready(function () {

	getAucTarget();
	
	$(".admin_updBtn").on("click", function(){
		var groupCd = $(this).attr("name");
		if (confirm(groupCd+"번 그룹을 연동하시겠습니까?\n연동 후 데이터 되돌리기는 불가능합니다.")) {
			param = {
				      "groupCd" : groupCd
				    };
			$("#loading-overlay").show();
		    
	        $.ajax({
				method : 'POST',
				async : true,
				url : '/updAuctionMember',
				dataType : "json",
				data : param,
				complete: function () {
		            $("#loading-overlay").hide();
		            location.reload();
		        }
			});
		}
	});
	
});

function getAucTarget(){
  $.ajax({
		method : 'POST',
		async : true,
		url : '/getAucTargetAjax',
		dataType : "json",
		success : function(data) {
			drawAucTarget(data.listA||[], data.listB||[], data.dt1||{}, data.dt2||{});
		}
	});
}

function drawAucTarget(listA, listB, dt1, dt2){
	var html1 = "GROUP1 연동 시각&nbsp;:&nbsp;" + dt1.dt;
	$("#dt1Txt").html(html1);
	var html2 = "GROUP2 연동 시각&nbsp;:&nbsp;" + dt2.dt;
	$("#dt2Txt").html(html2);

	$("#group1").html(buildGroupTable('GROUP1', listA));
	$("#group2").html(buildGroupTable('GROUP2', listB));
}

function buildGroupTable(title, list) {
	var html = "<div class='group-box'>";
	html += "<h3 style='margin-bottom:18px;'>" + title + "</h3>";
	html += "<table class='auc-table'>";

	html += "<colgroup>"
	     +  "<col style='width:11%'>"
	     +  "<col style='width:34%'>"
	     +  "<col style='width:9%'>"
	     +  "<col style='width:12%'>"
	     +  "<col style='width:12%'>"
	     +  "<col style='width:11%'>"
	     +  "<col style='width:11%'>"
	     +  "</colgroup>";

	html += "<thead><tr>"
	     +  "<th>순번</th>"
	     +  "<th style=\"text-align:center;\">닉네임</th>"
	     +  "<th>티어</th>"
	     +  "<th>주포지션</th>"
	     +  "<th>부포지션</th>"
	     +  "<th>포인트</th>"
	     +  "<th>팀장</th>"
	     +  "</tr></thead><tbody>";

	if (list && list.length > 0) {
		$.each(list, function(i, row) {
		  html += "<tr class=\"row_tr\">";
		  html += "<td class='td-center'>" + (row.ROW_RNK || "") + "</td>";

		  var nick = row.NICK || "";
		  html += "<td class='td-left' title='" + nick.replace(/'/g, "&apos;") + "'>" + nick + "</td>";

		  html += "<td class='td-center'>" + (row.TIER || "") + "</td>";
		  html += "<td class='td-center'>" + (row.MROLE || "") + "</td>";
		  html += "<td class='td-center'>" + (row.SROLE || "") + "</td>";

		  if (row.LEADERFLG === "Y") {
		        var inputId = "point_" + row.NO; 
		        var inputName = "POINT[" + row.NO + "]";
		        html += "<td class='td-center'>" +
		                "<input type='text' " +
		                "id='" + inputId + "' " +
		                "name='" + inputName + "' " +
		                "value='1000' " +
		                "style='width:56px; text-align:center;font-family: \"Noto Sans KR\", sans-serif;'" +
		                "maxlength='4' " +
		                "oninput=\"this.value=this.value.replace(/[^0-9]/g,'');\" />" +
		                "</td>";
	      } else {
	        html += "<td class='td-center'></td>";
	      }

		  html += "<td class='td-center'>" + (row.LEADERFLG === "Y" ? "★" : "") + "</td>";
		  html += "</tr>";
		});
	} else {
	  html += "<tr><td colspan='6' class='td-empty'>데이터가 없습니다</td></tr>";
	}

	html += "</tbody></table></div>";
	return html;
}

function esc(s){
	  s = (s == null) ? "" : String(s);
	  return s.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#39;");
}
</script>
