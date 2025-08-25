<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="container" id="auctionApp" data-state="STEP1">
  <section class="card step step1" id="step1">
    <h2 class="card-title">경매 대기실 입장</h2>
    <form id="joinForm" class="form-grid" onsubmit="return false;" autocomplete="off">
      <label for="code">입장 코드</label>
      <input type="text" id="code" maxlength="64" placeholder="ex) X0X0X0X" required/>
      <label for="nick">닉네임</label>
      <input type="text" id="nick" maxlength="50" required/>
      <button type="button" id="btnJoin" class="btn">입장하기</button>
    </form>
  </section>

  <section class="card step step2" id="step2" style="display:none;">
    <div class="row between" style="margin-bottom:12px;">
      <h2 class="card-title">경매 대기실</h2>
    </div>
    <div>
      <h3>팀장</h3>
      <ul id="leaderList" class="list"></ul>
    </div>
    <div class="row gap end">
      <button id="btnReady" class="btn sm">준비 완료</button>
      <button id="btnExit" class="btn sm danger">나가기</button>
      <button id="btnStart" class="btn sm" data-admin-only="true">경매 시작</button>
    </div>
  </section>

  <section class="card step step3" id="step3" style="display:none;">
    <div class="row between">
      <div class="pill" id="roundInfo">Round 1 · Pick 1</div>
      <div class="row gap">
        <div class="pill warn" id="serverClock">00:00</div>
        <button id="btnForceEnd" class="btn danger" data-admin-only="true">강제 종료</button>
      </div>
    </div>
    <div class="grid-3">
      <article class="panel" id="targetPanel">
        <h3>대상 선수</h3>
        <div class="player">
          <div class="player-name" id="mNick">-</div>
          <div class="player-meta" id="mMeta">티어 · 포지션</div>
          <div class="price"><span>현재가</span><strong id="currentPrice">0</strong></div>
          <div class="timer" id="countdown">--:--</div>
        </div>
      </article>
      <article class="panel" id="bidPanel">
        <h3>입찰</h3>
        <div class="budget">내 잔액 <strong id="myBudget">0</strong></div>
        <div class="row gap">
          <input type="number" id="bidAmount" min="0" step="10" class="input-number"/>
          <button class="btn primary" id="btnBid">입찰</button>
        </div>
        <div class="row gap quick">
          <button class="btn" data-inc="10" type="button">+10</button>
          <button class="btn" data-inc="20" type="button">+20</button>
          <button class="btn" data-inc="50" type="button">+50</button>
        </div>
        <div class="row end">
          <button class="btn success" id="btnAssign" data-admin-only="true">낙찰 확정</button>
        </div>
      </article>
      <article class="panel" id="teamBoard">
        <h3>팀 보드</h3>
        <table class="tbl" id="teamTable">
          <thead><tr><th>팀</th><th>잔액</th><th>TOP</th><th>JG</th><th>MID</th><th>AD</th><th>SUP</th></tr></thead>
          <tbody></tbody>
        </table>
      </article>
    </div>
    <article class="panel" id="eventFeed">
      <h3>실시간 로그</h3>
      <ul class="feed" id="feedList"></ul>
    </article>
  </section>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<link rel="stylesheet" href="<c:url value='/resources/css/auction.css'/>">

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>

<!-- 컨텍스트 패스 (항상 끝에 / 포함) -->
<script>var CTX = "<c:url value='/'/>";</script>

</script>