<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<!-- 컨테이너 -->
<div class="au-container container" id="auctionApp" data-state="STEP1"><!-- STEP1 | STEP2 | STEP3 -->

  <!-- STEP1: 코드/닉네임 입력 -->
  <section class="card step step1" id="step1">
    <h2 class="card-title">로비 입장</h2>
    <form id="joinForm" class="form-grid" onsubmit="return false;" autocomplete="off">
      <label for="code">경매 코드</label>
      <input type="text" id="code" maxlength="64" placeholder="예) ABC123  /  관리자는 ABC123/ADMINCODE" required/>

      <label for="nick">닉네임</label>
      <input type="text" id="nick" maxlength="50" required/>

      <div class="form-hint">관리자는 <b>경매코드/관리자토큰</b> 형태로 입력하세요.</div>

      <button type="button" id="btnJoin" class="btn primary">입장하기</button>
      <div class="form-error" id="formError"></div>
    </form>
  </section>

  <!-- STEP2: 경매 시작 대기 -->
  <section class="card step step2" id="step2" style="display:none;">
    <div class="row between">
      <h2 class="card-title">대기실</h2>
      <div class="pill" id="lobbyCount" aria-live="polite">리더 0 / 참가 0</div>
    </div>

    <div class="lobby-grid">
      <div>
        <h3>팀장 목록</h3>
        <ul id="leaderList" class="list" aria-live="polite"></ul>
      </div>
      <div>
        <h3>참여자 목록</h3>
        <ul id="viewerList" class="list" aria-live="polite"></ul>
      </div>
    </div>

    <div class="row end">
      <button id="btnReady" class="btn">준비완료</button>
      <button id="btnStart" class="btn primary" data-admin-only="true">경매 시작</button>
    </div>
  </section>

  <!-- STEP3: 경매 진행 -->
  <section class="card step step3" id="step3" style="display:none;">
    <div class="row between">
      <div class="pill" id="roundInfo">Round 1 · Pick 1</div>
      <div class="row gap">
        <div class="pill warn" id="serverClock">00:00</div>
        <button id="btnForceEnd" class="btn danger" data-admin-only="true">강제 종료</button>
      </div>
    </div>

    <div class="grid-3">
      <!-- 대상 선수 카드 -->
      <article class="panel" id="targetPanel">
        <h3>대상 선수</h3>
        <div class="player">
          <div class="player-name" id="mNick">-</div>
          <div class="player-meta" id="mMeta">티어 · 포지션</div>
          <div class="price">
            <span>현재가</span>
            <strong id="currentPrice">0</strong>
          </div>
          <div class="timer" id="countdown">--:--</div>
        </div>
      </article>

      <!-- 입찰 패널 -->
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
        <div class="form-error" id="bidError"></div>
        <div class="row end">
          <button class="btn success" id="btnAssign" data-admin-only="true">낙찰 확정</button>
        </div>
      </article>

      <!-- 팀 보드 -->
      <article class="panel" id="teamBoard">
        <h3>팀 보드</h3>
        <table class="tbl" id="teamTable">
          <thead>
            <tr><th>팀</th><th>잔액</th><th>TOP</th><th>JG</th><th>MID</th><th>AD</th><th>SUP</th></tr>
          </thead>
          <tbody><!-- AJAX --></tbody>
        </table>
      </article>
    </div>

    <!-- 이벤트 로그 -->
    <article class="panel" id="eventFeed">
      <h3>실시간 로그</h3>
      <ul class="feed" id="feedList" aria-live="polite"></ul>
    </article>
  </section>

</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<link rel="stylesheet" href="<c:url value='/resources/css/auction.css'/>">

<script>
/* 전역 스코프 오염 방지 */
(function($){
  "use strict";

  function setAdminMode(isAdmin){
    document.body.classList.toggle("admin", !!isAdmin);
    // data-admin-only 제어는 CSS가 처리
  }

  function setStep(step){
    $("#auctionApp").attr("data-state", step);
    document.body.setAttribute("data-state", step); // 상태 배지 색상 일치
    $(".step").hide();
    if(step==="STEP1") $("#step1").show();
    if(step==="STEP2") $("#step2").show();
    if(step==="STEP3") $("#step3").show();
  }

  function parseCode(raw){
    const s = (raw||"").trim();
    if(!s) return { baseCode:"", isAdmin:false, adminToken:"" };
    const i = s.indexOf("/");
    if(i<0) return { baseCode:s, isAdmin:false, adminToken:"" };
    return { baseCode:s.substring(0,i), isAdmin:true, adminToken:s.substring(i+1) };
  }

  function showFormError(msg){
    $("#formError").text(msg||"");
  }

  $(function(){

    // STEP1: 입장
    $("#btnJoin").on("click", function(){
      showFormError("");
      const codeRaw = $("#code").val();
      const nick = ($("#nick").val()||"").trim();
      const parsed = parseCode(codeRaw);

      if(!parsed.baseCode){ showFormError("경매 코드를 입력하세요."); return; }
      if(!nick){ showFormError("닉네임을 입력하세요."); return; }

      const role = parsed.isAdmin ? "VIEWER" : "LEADER";
      setAdminMode(parsed.isAdmin);

      $.ajax({
        url: "/auction/"+encodeURIComponent(parsed.baseCode)+"/lobby/join",
        type: "POST",
        contentType: "application/json; charset=UTF-8",
        data: JSON.stringify({
          code: parsed.baseCode,
          nick: nick,
          role: role,
          adminToken: parsed.isAdmin ? parsed.adminToken : null
        })
      }).done(function(res){
        if(!res || res.success!==true){
          showFormError(res && res.error ? (res.error.msg||"입장 실패") : "입장 실패");
          return;
        }
        $.getJSON("/auction/"+encodeURIComponent(parsed.baseCode)+"/overview")
          .done(function(snap){
            const st = (snap && snap.data && snap.data.status) || "SYNC";
            if(st==="ING"){ setStep("STEP3"); }
            else { setStep("STEP2"); }
          }).fail(function(){
            setStep("STEP2"); // 스냅샷 실패 시 대기실로
          });
      }).fail(function(xhr){
        showFormError("서버 오류 발생" + (xhr && xhr.status ? " ("+xhr.status+")" : ""));
      });
    });

    // 빠른 증가 버튼(추후 서버 연동 시 보완)
    $(document).on("click", ".quick .btn", function(){
      var inc = parseInt($(this).data("inc")||0,10);
      var $input = $("#bidAmount");
      var v = parseInt($input.val()||0,10);
      $input.val((v+inc) || inc);
    });

    // 초기 상태
    setStep("STEP1");
  });

})(window.jQuery || window.$);
</script>
