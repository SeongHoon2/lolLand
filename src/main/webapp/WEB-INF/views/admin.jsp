<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<div class="container">
<div class="admin_title">
  <div class="cluster cluster-left">
    <span id="dt1Txt"></span>
    <span id="btn1Area"></span>
  </div>
  <div class="cluster cluster-right">
    <span id="dt2Txt"></span>
    <span id="btn2Area"></span>
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

	$(document).on("click", ".admin_updBtn", function(){
		var groupCd = $(this).attr("name");
		if (confirm(groupCd+"번 그룹을 연동하시겠습니까?\n연동 후 데이터 되돌리기는 불가능합니다.")) {
			var param = { "groupCd" : groupCd };
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
  $("#dt1Txt").html("GROUP1 연동 시각&nbsp;:&nbsp;" + (dt1.dt||""));
  $("#dt2Txt").html("GROUP2 연동 시각&nbsp;:&nbsp;" + (dt2.dt||""));
  const code1 = "Code : " + (dt1.cd || "");
  const code2 = "Code : " + (dt2.cd || "");
  const stat1 = dt1.st || "";
  const stat2 = dt2.st || "";
  $("#group1").html(buildGroupTable('GROUP1', listA, code1, stat1));
  $("#group2").html(buildGroupTable('GROUP2', listB, code2, stat2));
  renderButton("#btn1Area", "1", stat1);
  renderButton("#btn2Area", "2", stat2);
}

function getStatusInfo(raw){
	switch ((raw || "").toUpperCase()) {
	    case "WAIT": return { label: "경매 종료(연동 대기)", className: "status-waiting" };
	    case "SYNC": return { label: "연동 완료(경매 대기중)", className: "status-synced" };
	    case "ING":  return { label: "경매 진행중", className: "status-active" };
	}
}

function renderButton(target, groupCd, status){
	var s = (status||"").toUpperCase();
	var html = "";
	if(s === "WAIT"){
		html = "<button name='"+groupCd+"' class='admin_updBtn'>연동</button>";
	}else if(s === "SYNC"){
		html = "<button name='"+groupCd+"' class='admin_startBtn'>경매 시작</button>";
	}else{
		html = "<button class='admin_ingBtn' disabled>경매 진행중</button>";
	}
	$(target).html(html);
}

function buildGroupTable(title, list, codeText, statusText) {
  const st = getStatusInfo(statusText);

  var html = "<div class='group-box'>";
  html += "<div class='group-header'>";
  html +=   "<h3 class='group-title'>" + title + "</h3>";
  html +=   "<div class='group-code-wrap'>";
  html +=     "<span class='group-code-badge'>" + (codeText || "") + "</span>";
  html +=     "<span class='group-code-status " + st.className + "' title='" + st.label + "'>" + st.label + "</span>";
  html +=   "</div>";
  html += "</div>";
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
        html += "<td class='td-center'>"
             +  "<input type='text' id='" + inputId + "' name='" + inputName + "' value='1000' "
             +  "style='width:56px; text-align:center;font-family: \"Noto Sans KR\", sans-serif;' maxlength='4' "
             +  "oninput=\"this.value=this.value.replace(/[^0-9]/g,'');\" />"
             +  "</td>";
      } else {
        html += "<td class='td-center'></td>";
      }

      html += "<td class='td-center'>" + (row.LEADERFLG === "Y" ? "★" : "") + "</td>";
      html += "</tr>";
    });
  } else {
    html += "<tr><td colspan='7' class='td-empty'>데이터가 없습니다</td></tr>";
  }

  html += "</tbody></table></div>";
  return html;
}
</script>
