<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<div class="container">
<div class="admin_title">
<span id="dt1Txt"></span>&nbsp;&nbsp;<span><button name="1" class="admin_updBtn">최신화</button></span>
&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;&nbsp;
<span id="dt2Txt"></span>&nbsp;&nbsp;<span><button name="2" class="admin_updBtn">최신화</button></span>
</div>
<div class="admin_body">
  <div class="group-box" id="group1"></div>
  <div class="group-box" id="group2"></div>
</div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<link rel="stylesheet" href="<c:url value='/resources/css/admin.css'/>">

<script>
$(document).ready(function () {
	$(".admin_updBtn").on("click", function(){
		var groupCd = $(this).attr("name");
		if (confirm(groupCd+"번 그룹을 연동하시겠습니까?\n연동 후 데이터 되돌리기는 불가능합니다.")) {
			param = {
				      "groupCd" : groupCd
				    };
	        $.ajax({
				method : 'POST',
				async : true,
				url : '/updAuctionMember',
				dataType : "json",
				data : param,
				success : function(data) {
					alert("구글스프레드 시트 연동 성공");
				}
			});
		}
	});

	getAucTarget();
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
	var html1 = "GROUP1 최신화 시각&nbsp;:&nbsp;" + dt1.dt;
	$("#dt1Txt").html(html1);
	var html2 = "GROUP2 최신화 시각&nbsp;:&nbsp;" + dt2.dt;
	$("#dt2Txt").html(html2);

	$("#group1").html(buildGroupTable('GROUP1', listA));
	$("#group2").html(buildGroupTable('GROUP2', listB));
}

function buildGroupTable(title, list) {
	  var html = "<div class='group-box'>";
	  html += "<h3 style='margin-bottom:8px;'>" + title + "</h3>";
	  html += "<table class='auc-table'>";
	  html += "<thead><tr>";
	  html += "<th>순번</th>";
	  html += "<th>닉네임</th>";
	  html += "<th>티어</th>";
	  html += "<th>주포지션</th>";
	  html += "<th>부포지션</th>";
	  html += "<th>팀장</th>";
	  html += "</tr></thead><tbody>";

	  if (list && list.length > 0) {
	    $.each(list, function(i, row) {
	      html += "<tr>";
	      html += "<td class='td-center'>" + (row.ROW_RNK || "") + "</td>";
	      html += "<td class='td-left'>"   + (row.NICK || "") + "</td>";
	      html += "<td class='td-center'>" + (row.TIER || "") + "</td>";
	      html += "<td class='td-center'>" + (row.MROLE || "") + "</td>";
	      html += "<td class='td-center'>" + (row.SROLE || "") + "</td>";
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