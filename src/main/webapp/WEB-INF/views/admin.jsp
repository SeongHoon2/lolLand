<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<div class="container">
<div class="admin_title">
<span>GROUP1 최신화 시각&nbsp;:&nbsp;yyyy-mm-dd hh:mm:ss</span>&nbsp;&nbsp;
<span><button name="1" class="admin_updBtn">최신화</button></span>
&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;&nbsp;
<span>GROUP2 최신화 시각&nbsp;:&nbsp;yyyy-mm-dd hh:mm:ss</span>&nbsp;&nbsp;
<span><button name="2" class="admin_updBtn">최신화</button></span>
</div>
<div class="admin_body"></div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<link rel="stylesheet" href="<c:url value='/resources/css/admin.css'/>">

<script>
$(document).ready(function () {
	$(".admin_updBtn").on("click", function(){
		var groupCd = $(this).attr("name");
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
			}
		});
	});
});
</script>