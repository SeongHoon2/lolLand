<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>.</title>
  <link rel="stylesheet" href="<c:url value='/resources/css/common.css'/>">
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <link rel="shortcut icon" href="/resources/img/logo.png" type="image/x-icon">
  <link rel="icon" href="/resources/img/logo.png" type="image/x-icon">
</head>
<body>
<header class="header">
  <div class="container">
    <h1 class="brand">.</h1>
	<nav class="nav">
	  <a href="<c:url value='/auction'/>">경매</a>
	  <div class="menu">
	    <a href="<c:url value='/admin'/>" class="menu-trigger" role="button" aria-haspopup="true" aria-expanded="false">관리</a>
	    <div class="dropdown" role="menu">
	      <a role="menuitem" href="<c:url value='/createAuction'/>">경매 생성</a>
	      <a role="menuitem" href="<c:url value='/manageAuction'/>">경매 관리</a>
	    </div>
	  </div>
	</nav>
  </div>
</header>

<script>
$(document).ready(function () {
	$('.menu-trigger').on('click', function(e){
	  e.preventDefault();
	  const $menu = $(this).closest('.menu');
	  const open = $menu.toggleClass('open').hasClass('open');
	  $(this).attr('aria-expanded', open ? 'true' : 'false');
	});

	$(document).on('click', function(e){
	  const $m = $('.menu');
	  if(!$m.is(e.target) && $m.has(e.target).length===0){
	    $m.removeClass('open').find('.menu-trigger').attr('aria-expanded','false');
	  }
	});

	$('.menu').on('mouseenter', function(){ $(this).addClass('open'); });
	$('.menu').on('mouseleave', function(){ $(this).removeClass('open'); });

});
</script>