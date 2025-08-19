<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>lolLand</title>
  <link rel="stylesheet" href="<c:url value='/resources/css/common.css'/>">
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>
<header class="header">
  <div class="container">
    <!-- <h1 class="brand">lolLand</h1> -->
    <h1 class="brand">.</h1>
    <nav class="nav">
      <a href="<c:url value='/auction'/>">경매</a>
      <a href="<c:url value='/admin'/>  ">관리</a>
    </nav>
  </div>
</header>

<script>
$(document).ready(function () {
	
});
</script>