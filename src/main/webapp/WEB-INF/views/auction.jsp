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
      <button id="btnStart" class="btn sm" data-admin-only="true">경매 시작</button>
      <button id="btnExit" class="btn sm danger">나가기</button>
    </div>
  </section>
  
  <section class="card step step3" id="step3" style="display:none;">
    <div class="au-grid-2 tight">
      <article class="panel" id="teamSpreadsheet">
        <h3>팀 리스트</h3>
        <div class="tbl-scroll tall">
          <table class="tbl sheet" id="teamSheet">
            <colgroup>
              <col style="width:70px"><col style="width:70px"><col style="width:70px">
              <col style="width:110px">
              <col style="width:180px"><col style="width:180px"><col style="width:180px"><col style="width:180px"><col style="width:180px">
            </colgroup>
            <thead>
              <tr>
                <th colspan="3" scope="colgroup">포인트</th>
                <th rowspan="2" scope="col">구분</th>
                <th rowspan="2" scope="col">팀장</th>
                <th rowspan="2" scope="col">팀원1</th>
                <th rowspan="2" scope="col">팀원2</th>
                <th rowspan="2" scope="col">팀원3</th>
                <th rowspan="2" scope="col">팀원4</th>
              </tr>
              <tr>
                <th scope="col">초기</th>
                <th scope="col">사용</th>
                <th scope="col">잔여</th>
              </tr>
            </thead>
            <tbody id="teamSheetBody">
              <c:forEach begin="1" end="8" var="t">
                <tr data-team="${t}">
                  <td class="num init" rowspan="4">0</td>
                  <td class="num used" rowspan="4">0</td>
                  <td class="num left" rowspan="4">0</td>
                  <td class="sec">닉네임</td>
                  <td class="leader nick">-</td>
                  <td class="m1 nick">-</td>
                  <td class="m2 nick">-</td>
                  <td class="m3 nick">-</td>
                  <td class="m4 nick">-</td>
                </tr>
                <tr data-team="${t}">
                  <td class="sec">낙찰가</td>
                  <td class="leader point">-</td>
                  <td class="m1 point">-</td>
                  <td class="m2 point">-</td>
                  <td class="m3 point">-</td>
                  <td class="m4 point">-</td>
                </tr>
                <tr data-team="${t}">
                  <td class="sec">티어</td>
                  <td class="leader tier">-</td>
                  <td class="m1 tier">-</td>
                  <td class="m2 tier">-</td>
                  <td class="m3 tier">-</td>
                  <td class="m4 tier">-</td>
                </tr>
                <tr data-team="${t}">
                  <td class="sec">주포지션</td>
                  <td class="leader pos">-</td>
                  <td class="m1 pos">-</td>
                  <td class="m2 pos">-</td>
                  <td class="m3 pos">-</td>
                  <td class="m4 pos">-</td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </article>

      <article class="panel" id="playerPanel">
        <h3>
          입찰 콘솔&nbsp;&nbsp;&nbsp;
          <button class="btn success sm" id="btnBegin" data-admin-only="true" disabled>입찰 시작</button>
        </h3>

        <div class="console tall-console console-xl">
			<div class="kv-row">
			  <div class="kv">
			    <span class="k">입찰 대상</span>
			    <span class="v" id="currentTarget">-</span>
			  </div>
			</div>
			<div class="kv-grid">
			  <!-- 1행 -->
			  <div class="kv two-line span-3">
			    <span class="k">현재 경매가</span>
			    <span class="v" id="currentPrice">0</span>
			  </div>
			  <div class="kv two-line span-3">
			    <span class="k">현재 입찰자</span>
			    <span class="v" id="bidStatus">-</span>
			  </div>

			  <!-- 2행 -->
			  <div class="kv two-line span-2">
			    <span class="k">평균 경매가</span>
			    <span class="v" id="avgPrice">-</span>
			  </div>
			  <div class="kv two-line span-2">
			    <span class="k">내 잔액</span>
			    <span class="v">
			      <span id="myBudget">0</span>
			      <span id="myBudgetHold" class="muted" style="margin-left:6px;"></span>
			    </span>
			  </div>
			  <div class="kv two-line span-2">
			    <span class="k">남은 시간</span>
			    <span class="v" id="countdown">--</span>
			  </div>
			</div>
			
			<div class="controls-grid">
			  <div class="left row1">
			    <input type="number"
			           id="bidAmount"
			           min="0"
			           step="10"
			           class="input-number bid-input"
			           placeholder="금액 입력 (10 단위)"/>
			  </div>
			  <div class="right bid-span">
			  <button class="btn primary btnBid" id="btnBid" title="입찰 (Enter 가능)">
			    <span class="btn-main">입찰</span>
			    <span class="btn-sub">(엔터 가능)</span>
			  </button>
			  </div>
			  <div class="left row2">
			    <div class="step-buttons">
			      <button type="button" class="btn step" data-step="10">+10</button>
			      <button type="button" class="btn step" data-step="20">+20</button>
			      <button type="button" class="btn step" data-step="50">+50</button>
			      <button type="button" class="btn warn" id="btnAllinQuick">올인</button>
			    </div>
			  </div>
			</div>
			
			<div class="hint" aria-live="polite">경매 최소 단위 : ~100:+10 / 100~400:+20 / 400~:+50 (모든 입찰 10단위)</div>
        </div>

        <h3 style="margin-top:14px">경매 선수 리스트</h3>
        <div class="tbl-scroll tall players compact-players">
          <table class="tbl sheet" id="playerTable">
            <colgroup>
              <col style="width:56px">
              <col style="width:280px">
              <col style="width:100px">
              <col style="width:90px">
              <col style="width:90px">
              <col style="width:100px">
            </colgroup>
            <thead>
              <tr>
                <th>#</th><th>닉네임</th><th>티어</th><th>주</th><th>부</th><th>낙찰</th>
              </tr>
            </thead>
            <tbody id="playerBody">
              <c:forEach begin="1" end="40" var="i">
                <tr data-row="${i}">
                  <td>${i}</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </article>
    </div>
  </section>

  <section class="card step step4" id="step4" style="display:none;">
    <div class="row between" style="margin-bottom:12px;">
      <h2 class="card-title">최종 팀구성</h2>
      <div class="row gap">
        <button id="btnBackToLobby" class="btn sm">처음으로</button>
      </div>
    </div>

    <article class="panel">
      <div class="tbl-scroll">
        <table class="tbl sheet" id="finalTeamSheet">
          <colgroup>
            <col style="width:70px"><col style="width:70px"><col style="width:70px">
            <col style="width:110px">
            <col style="width:180px"><col style="width:180px"><col style="width:180px"><col style="width:180px"><col style="width:180px">
          </colgroup>
          <thead>
            <tr>
              <th colspan="3" scope="colgroup">포인트</th>
              <th rowspan="2" scope="col">구분</th>
              <th rowspan="2" scope="col">팀장</th>
              <th rowspan="2" scope="col">팀원1</th>
              <th rowspan="2" scope="col">팀원2</th>
              <th rowspan="2" scope="col">팀원3</th>
              <th rowspan="2" scope="col">팀원4</th>
            </tr>
            <tr>
              <th scope="col">초기</th>
              <th scope="col">사용</th>
              <th scope="col">잔여</th>
            </tr>
          </thead>
          <tbody id="finalTeamSheetBody">
            <c:forEach begin="1" end="8" var="t">
              <tr data-team="${t}">
                <td class="num init" rowspan="4">0</td>
                <td class="num used" rowspan="4">0</td>
                <td class="num left" rowspan="4">0</td>
                <td class="sec">닉네임</td>
                <td class="leader nick">-</td>
                <td class="m1 nick">-</td>
                <td class="m2 nick">-</td>
                <td class="m3 nick">-</td>
                <td class="m4 nick">-</td>
              </tr>
              <tr data-team="${t}">
                <td class="sec">낙찰가</td>
                <td class="leader point">-</td>
                <td class="m1 point">-</td>
                <td class="m2 point">-</td>
                <td class="m3 point">-</td>
                <td class="m4 point">-</td>
              </tr>
              <tr data-team="${t}">
                <td class="sec">티어</td>
                <td class="leader tier">-</td>
                <td class="m1 tier">-</td>
                <td class="m2 tier">-</td>
                <td class="m3 tier">-</td>
                <td class="m4 tier">-</td>
              </tr>
              <tr data-team="${t}">
                <td class="sec">주포지션</td>
                <td class="leader pos">-</td>
                <td class="m1 pos">-</td>
                <td class="m2 pos">-</td>
                <td class="m3 pos">-</td>
                <td class="m4 pos">-</td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </article>
  </section>

</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
<link rel="stylesheet" href="<c:url value='/resources/css/auction.css'/>">
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
<script>var CTX = "<c:url value='/'/>";</script>

<script>
(function($){
  "use strict";

  var STOMP=null, STOMP_SUB=null, STOMP_AUC_SUB=null;
  var RECONNECT_TIMER=null, RECONNECT_WAIT=300, MAX_WAIT=5000;
  var CNT_TIMER=null, LAST_PICK_ID=null;
  var PENDING_ASSIGN = null;
  var AUC_NEXT_MIN = null, AUC_GRACE = false;

  var URLS = {
    ws: "<c:url value='/ws-auction'/>",
    restore: "<c:url value='/api/auction/restore'/>",
    auctionBase: "<c:url value='/api/auction/'/>"
  };

  var G={ code:null, aucSeq:null, nick:null, role:null, currentPickId:null, teamRowById:null, myTeamId:null, leaderNickByTeamId:{} };
  var PENDING_HILITE = null;

  function hasJoined(){
    return !!(G.code && G.nick);
  }

  window.addEventListener("pagehide", function(){
    try { sessionStorage.setItem("auc.reloading","1"); } catch(e){}
  });

  function setStep(step){
	  $("#auctionApp").attr("data-state", step);
	  document.body.setAttribute("data-state", step);
	  $(".card.step").hide();   // 섹션만 숨기기
	  
	  if(step==="STEP1") { $("#step1").show(); }

	  if(step==="STEP2") { $("#step2").show(); }

	  if(step==="STEP3"){
	    // ★ ROLE이 아직 세팅되지 않은 경우 잠시 대기 후 재시도 (새로고침 직후 튕김 방지)
	    if (!(G.role === 'ADMIN_GHOST' || G.role === 'LEADER')) {
	      try {
	        // 세션스토리지에 role이 있으면 우선 적용(조기 복구)
	        var savedRole = sessionStorage.getItem("auc.role");
	        if (savedRole) {
	          G.role = savedRole;
	          if (G.role === 'ADMIN_GHOST') { try { document.body.classList.add('admin'); } catch(e){} }
	        }
	      } catch(e){}

	      if (!(G.role === 'ADMIN_GHOST' || G.role === 'LEADER')) {
	        setTimeout(function(){ setStep('STEP3'); }, 80);
	        return;
	      }
	    }

	    if (!hasJoined()) { return; } // 코드/닉이 없으면 대기 (스냅샷 호출 금지)

	    $("#step3").show();
	    syncState();
	    if (G.code) { loadStep3(); } else { setTimeout(function(){ if (G.code) loadStep3(); }, 120); }
	    if (STOMP && STOMP.connected) { subscribeAuction(); }
	    if (G.role === 'ADMIN_GHOST') { prepareRound(); }
	    return;
	  }

	  if(step==="STEP4"){
	    $("#step4").show();
	    try { if (CNT_TIMER) { clearInterval(CNT_TIMER); CNT_TIMER=null; } } catch(e){}
	    disconnectStomp();
	    if (G.code) loadStep4();
	  }
	}


  function renderLobby(data){
    var leaders = (data && data.leaders) || [];
    $("#leaderList").html(leaders.map(function(m){
      var showReady = (m.ONLINE_YN==="Y" && m.READY_YN==="Y");
      var ready = showReady ? " ✅" : "";
      var stateClass = (m.ONLINE_YN==="Y") ? "online" : "offline";
      var stateText = (m.ONLINE_YN==="Y") ? "온라인" : "오프라인";
      return "<li><span>"+m.NICK+"</span><span class='"+stateClass+"'>"+stateText+ready+"</span></li>";
    }).join(""));

    var me = leaders.find(function(m){ return m && m.NICK === G.nick; });
    var isOnline = !!(me && me.ONLINE_YN==="Y");
    var isReady  = !!(me && me.READY_YN==="Y" && isOnline);

    var $btn = $("#btnReady");
    $btn.text(isReady ? "준비 해제" : "준비 완료")
        .data("ready", isReady)
        .attr("aria-pressed", isReady ? "true" : "false")
        .toggleClass("outline", isReady)
        .prop("disabled", !isOnline)
        .attr("title", isOnline ? "" : "오프라인 상태에서는 변경할 수 없습니다.");
  }

  function subscribeLobby(){
    if(!STOMP || !STOMP.connected || !G.aucSeq) return;
    if(STOMP_SUB){ try{ STOMP_SUB.unsubscribe(); }catch(e){} STOMP_SUB=null; }
    STOMP_SUB = STOMP.subscribe("/topic/lobby."+G.aucSeq, function(frame){
      try {
        var msg = JSON.parse(frame.body||"{}");
        if (!msg) return;
        if (msg.status === 'END') {
          if (hasJoined()) {
            var role = G.role;
            if (role === 'ADMIN_GHOST' || role === 'LEADER') {
              setStep('STEP4');
            } else {
              alert('권한이 없어 결과 화면을 볼 수 없습니다.');
              setStep('STEP2');
            }
          }
          return;
        }
        if (msg.status === 'ING') {
        	if (hasJoined() && (G.role === 'ADMIN_GHOST' || G.role === 'LEADER')) {
        		setStep('STEP3');
        	}
        }
        renderLobby(msg);
      } catch(e){}
    });
  }

  function scheduleReconnect(){
    if(RECONNECT_TIMER) return;
    RECONNECT_TIMER = setTimeout(function(){
      RECONNECT_TIMER = null;
      RECONNECT_WAIT = Math.min(RECONNECT_WAIT*1.6, MAX_WAIT);
      connectStomp();
    }, RECONNECT_WAIT);
  }

  function connectStomp(){
    if(STOMP && STOMP.connected) { subscribeLobby(); return; }
    var sock = new SockJS(URLS.ws);
    STOMP = Stomp.over(sock);
    STOMP.debug = null;

    sock.onclose = function(){
      if(["STEP2","STEP3"].includes($("#auctionApp").attr("data-state"))){
        scheduleReconnect();
      }
    };

    STOMP.connect({}, function(){
      RECONNECT_WAIT = 300;
      if(RECONNECT_TIMER){ clearTimeout(RECONNECT_TIMER); RECONNECT_TIMER=null; }
      subscribeLobby();
      subscribeAuction();
      if ($("#auctionApp").attr("data-state")==="STEP3") { syncState(); }
    }, function(){
      scheduleReconnect();
    });
  }

  function disconnectStomp(){
    if(STOMP){
      try{ if(STOMP_SUB) STOMP_SUB.unsubscribe(); }catch(e){}
      try{ if(STOMP_AUC_SUB) STOMP_AUC_SUB.unsubscribe(); }catch(e){}
      try{ STOMP.disconnect(function(){}); }catch(e){}
    }
    STOMP=null; STOMP_SUB=null; STOMP_AUC_SUB=null;
  }

  function ensureConnectedThen(fn){
    if (STOMP && STOMP.connected) { fn(); return; }
    connectStomp();
    var tries = 0, timer = setInterval(function(){
      if (STOMP && STOMP.connected){ clearInterval(timer); fn(); }
      else if (++tries > 50){ clearInterval(timer); alert("서버 연결 실패"); }
    }, 100);
  }

  function afterJoin(code){
    $.getJSON(URLS.auctionBase + encodeURIComponent(code) + "/overview").done(function(snap){
      var data = snap && snap.data || {};
      renderLobby(data);
      var st = data.status || "WAIT";
      G.code   = code;
      G.aucSeq = data.aucSeq || G.aucSeq;
      if (st === "ING") {
        setStep("STEP3");
      } else if (st === "END") {
        var role = G.role;
        if (role === 'ADMIN_GHOST' || role === 'LEADER') {
          setStep("STEP4");
        } else {
          alert('권한이 없어 결과 화면을 볼 수 없습니다.');
          setStep("STEP2");
        }
      } else {
        setStep("STEP2");
      }
      if (st === "ING") { loadStep3(); }
      if (st !== "END") connectStomp();
    }).fail(function(){
      setStep("STEP2");
      connectStomp();
    });
  }

  $("#btnJoin").on("click", function(){
    var code = ($("#code").val()||"").trim();
    var nick = ($("#nick").val()||"").trim();
    if(!code){ alert("입장 코드를 입력하세요."); return; }
    if(!nick){ alert("닉네임을 입력하세요."); return; }
    $.ajax({
      url: URLS.auctionBase + encodeURIComponent(code) + "/lobby/join",
      type: "POST",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify({ code: code, nick: nick })
    }).done(function(res){
      if(!res || res.success!==true){
        alert(res && res.error ? (res.error.msg||"입장 실패") : "입장 실패"); return;
      }
      var role = (res && res.data && res.data.role) ? res.data.role : (res && res.payload && res.payload.role) ? res.payload.role: null;
      G.role = role;

      if (G.role === 'ADMIN_GHOST') {
        try { document.body.classList.add('admin'); } catch(e){}
      }

      try{
        sessionStorage.setItem("auc.last", JSON.stringify({code:code, nick:nick}));
        if (G.role) sessionStorage.setItem("auc.role", G.role);
      }catch(e){}
      G.nick=nick; afterJoin(code);
    }).fail(function(xhr){ alert("서버 오류 발생" + (xhr && xhr.status ? " ("+xhr.status+")" : "")); });
  });

  $("#btnReady").on("click", function(){
    if(!G.aucSeq){ alert("세션 없음"); return; }
    var isReady = $("#btnReady").data("ready") === true;
    var dest = isReady ? ("/app/lobby."+G.aucSeq+".unready") : ("/app/lobby."+G.aucSeq+".ready");
    ensureConnectedThen(function(){
      try { STOMP.send(dest, {}, ""); }
      catch(e){ alert("전송 실패"); }
    });
  });

  $("#btnExit").on("click", function(){
    if(!G.code){ setStep("STEP1"); return; }
    $.ajax({
      url: URLS.auctionBase + encodeURIComponent(G.code) + "/lobby/exit",
      type: "POST",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify({})
    }).done(function(){
      try{
        sessionStorage.removeItem("auc.last");
        sessionStorage.removeItem("auc.reloading");
        sessionStorage.removeItem("auc.role");
      }catch(e){}
      disconnectStomp();
      location.reload();
    }).fail(function(){ alert("대기실 나가기 실패"); });
  });

  $("#btnStart").on("click", function(){
    $.ajax({
      url: URLS.auctionBase + encodeURIComponent(G.code) + '/lobby/start',
      type: 'POST',
      contentType: 'application/json',
      data: '{}'
    }).done(function(r){
      if (!(r && r.success)) {
        alert(r && r.error ? r.error.msg : '시작 실패');
      }
    }).fail(function(){
      alert('시작 요청 오류');
    });
  });

  function prepareRound(){
    if(!G.code){ return; }
    $.ajax({
      url: URLS.auctionBase + encodeURIComponent(G.code) + "/step3/begin",
      type: "POST",
      contentType: "application/json; charset=UTF-8",
      data: "{}"
    }).done(function(res){
      if (res && res.success===true && res.data){
        updateAuctionConsole(res.data);
      }
    });
  }

  $(function(){
    tryRestore();
    $("#bidAmount").prop("readonly", false);
  });

  function tryRestore(){
	  var isReload = false;
	  try { isReload = sessionStorage.getItem("auc.reloading")==="1"; } catch(e){}

	  var cached=null;
	  try { cached = JSON.parse(sessionStorage.getItem("auc.last")||"null"); } catch(e){}

	  // 저장된 role이 있으면 즉시 적용(화면 표시 안정화)
	  try {
	    var savedRole = sessionStorage.getItem("auc.role");
	    if (savedRole) {
	      G.role = savedRole;
	      if (G.role === 'ADMIN_GHOST') { try { document.body.classList.add('admin'); } catch(e){} }
	    }
	  } catch(e){}

	  // 1) 강제 새로고침 + 캐시 존재 → 즉시 재조인
	  if(isReload && cached && cached.code && cached.nick){
	    try{ sessionStorage.removeItem("auc.reloading"); }catch(e){}
	    $.ajax({
	      url: URLS.auctionBase + encodeURIComponent(cached.code) + "/lobby/join",
	      type: "POST",
	      contentType: "application/json; charset=UTF-8",
	      data: JSON.stringify({ code: cached.code, nick: cached.nick })
	    }).done(function(res2){
	      if(res2 && res2.success===true){
	        // ★ 재조인 응답에서 role 확정 + 저장
	        var role = (res2.data && res2.data.role) ? String(res2.data.role)
	                 : (res2.payload && res2.payload.role) ? String(res2.payload.role)
	                 : null;
	        if (role) {
	          G.role = role;
	          try { sessionStorage.setItem('auc.role', role); } catch(e){}
	          if (role === 'ADMIN_GHOST') { try { document.body.classList.add('admin'); } catch(e){} }
	        }
	        G.nick = cached.nick;
	        afterJoin(cached.code);
	      } else {
	        setStep("STEP1");
	      }
	    }).fail(function(){ setStep("STEP1"); });
	    return;
	  }

	  // 2) 서버 세션 복구 시도
	  $.getJSON(URLS.restore).done(function(res){
	    var data = res && res.data;
	    if (res && res.success===true && data){
	      G.aucSeq = data.aucSeq;
	      G.code   = data.code;
	      G.nick   = data.nick;

	      // restore 응답에 role이 있으면 확정 + 저장
	      var role = (data.role === 'null' || data.role === 'undefined' || data.role == null || data.role === '') ? null : String(data.role);
	      if (role) {
	        G.role = role;
	        try { sessionStorage.setItem('auc.role', role); } catch(e){}
	        if (role === 'ADMIN_GHOST') { try { document.body.classList.add('admin'); } catch(e){} }
	      }

	      renderLobby(data);

	      if (data.status === "ING") {
	        var roleOk = (G.role === 'ADMIN_GHOST' || G.role === 'LEADER');
	        if (!roleOk) {
	          // 2-1) ROLE 없으면 캐시로 재조인 시도
	          var cached2=null; try{ cached2 = JSON.parse(sessionStorage.getItem("auc.last")||"null"); }catch(e){}
	          if (cached2 && cached2.code && cached2.nick) {
	            $.ajax({
	              url: URLS.auctionBase + encodeURIComponent(cached2.code) + "/lobby/join",
	              type: "POST",
	              contentType: "application/json; charset=UTF-8",
	              data: JSON.stringify({ code: cached2.code, nick: cached2.nick })
	            }).done(function(res2){
	              if(res2 && res2.success===true){
	                // ★ 재조인 응답에서 role 확정 + 저장
	                var role2 = (res2.data && res2.data.role) ? String(res2.data.role)
	                          : (res2.payload && res2.payload.role) ? String(res2.payload.role)
	                          : null;
	                if (role2) {
	                  G.role = role2;
	                  try { sessionStorage.setItem('auc.role', role2); } catch(e){}
	                  if (role2 === 'ADMIN_GHOST') { try { document.body.classList.add('admin'); } catch(e){} }
	                }
	                G.nick = cached2.nick;
	                afterJoin(cached2.code);
	              } else {
	                setStep("STEP2"); connectStomp();
	              }
	            }).fail(function(){ setStep("STEP2"); connectStomp(); });
	            return; // 재조인 완료까지 대기
	          }
	        }
	        // ROLE 정상 또는 재조인 불필요
	        setStep("STEP3");
	        loadStep3();
	        connectStomp();
	      }
	      else if (data.status === "END") {
	        var r2 = G.role || role;
	        if (r2 === 'ADMIN_GHOST' || r2 === 'LEADER') { setStep("STEP4"); }
	        else { setStep("STEP2"); }
	      }
	      else {
	        setStep("STEP2");
	        connectStomp();
	      }
	    }
	    // restore 성공X → 캐시 재조인 시도
	    else if(cached && cached.code && cached.nick){
	      $.ajax({
	        url: URLS.auctionBase + encodeURIComponent(cached.code) + "/lobby/join",
	        type: "POST",
	        contentType: "application/json; charset=UTF-8",
	        data: JSON.stringify({ code: cached.code, nick: cached.nick })
	      }).done(function(res2){
	        if(res2 && res2.success===true){
	          // ★ 재조인 응답에서 role 확정 + 저장
	          var role = (res2.data && res2.data.role) ? String(res2.data.role)
	                   : (res2.payload && res2.payload.role) ? String(res2.payload.role)
	                   : null;
	          if (role) {
	            G.role = role;
	            try { sessionStorage.setItem('auc.role', role); } catch(e){}
	            if (role === 'ADMIN_GHOST') { try { document.body.classList.add('admin'); } catch(e){} }
	          }
	          G.nick = cached.nick;
	          afterJoin(cached.code);
	        } else {
	          setStep("STEP1");
	        }
	      }).fail(function(){ setStep("STEP1"); });
	    } else {
	      setStep("STEP1");
	    }
	  }).fail(function(){
	    // restore 호출 자체 실패 → 캐시 재조인 시도
	    if(cached && cached.code && cached.nick){
	      $.ajax({
	        url: URLS.auctionBase + encodeURIComponent(cached.code) + "/lobby/join",
	        type: "POST",
	        contentType: "application/json; charset=UTF-8",
	        data: JSON.stringify({ code: cached.code, nick: cached.nick })
	      }).done(function(res2){
	        if(res2 && res2.success===true){
	          // ★ 재조인 응답에서 role 확정 + 저장
	          var role = (res2.data && res2.data.role) ? String(res2.data.role)
	                   : (res2.payload && res2.payload.role) ? String(res2.payload.role)
	                   : null;
	          if (role) {
	            G.role = role;
	            try { sessionStorage.setItem('auc.role', role); } catch(e){}
	            if (role === 'ADMIN_GHOST') { try { document.body.classList.add('admin'); } catch(e){} }
	          }
	          G.nick = cached.nick;
	          afterJoin(cached.code);
	        } else {
	          setStep("STEP1");
	        }
	      }).fail(function(){ setStep("STEP1"); });
	    } else {
	      setStep("STEP1");
	    }
	  });
	}

  function loadStep3(){
    $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/step3/snapshot")
      .done(function(res){
        if(!res || res.success!==true){ alert(res && res.error ? res.error.msg : "스냅샷 실패"); return; }
        var data = res.data || {};
        renderTeamSheet(data.teams || [], data.teamMembers || {});
        if (PENDING_ASSIGN) {
          applyAssignmentToTeamSheet(PENDING_ASSIGN);
          PENDING_ASSIGN = null;
        }
        renderPlayerTable(data.players || [], data.teamMembers || {});
        var me = (data.teams||[]).find(function(t){ return String(t.LEADER_NICK) === String(G.nick); });
        $("#myBudget").text(me ? (me.BUDGET_LEFT||0) : 0);

        if (PENDING_HILITE){ highlightCurrentByNick(PENDING_HILITE); PENDING_HILITE = null; }
        if (G.currentPickId){
          $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + G.currentPickId + "/controls")
            .done(toggleControlsFromResp);
        }

        if (G.myTeamId && data.teamMembers) {
          var ml = data.teamMembers[String(G.myTeamId)] || [];
          var full = ml.length >= 4;
		  $("#btnBid, #bidAmount, #btnAllinQuick").prop("disabled", full);
		  $(".step-buttons .btn.step").prop("disabled", full);
		  $(".controls-grid").toggleClass("is-disabled", full);
          $(".hint").text(full ? "팀 정원 5명 완료" : "경매 단위 :  ~100 : +10 / 100~400 : +20 / 400~ : +50");
        }
        setTimeout(syncState, 0);
      })
      .fail(function(xhr){ alert("스냅샷 호출 오류" + (xhr && xhr.status ? " ("+xhr.status+")" : "")); });
  }

  function renderTeamSheet(teams, membersByTeam){
    for (var i=1;i<=8;i++){
      var t = teams[i-1] || null;
      var $rows = $('#teamSheetBody').find('tr[data-team="'+i+'"]');

      var budget = t ? (t.BUDGET||0) : 0;
      var left   = t ? (t.BUDGET_LEFT||0) : 0;
      var used   = t ? (t.USED||0) : 0;

      $rows.eq(0).find('td.init').text(budget);
      $rows.eq(0).find('td.used').text(used);
      $rows.eq(0).find('td.left').text(left);
      $rows.eq(0).find('td.leader.nick').text(t ? (t.LEADER_NICK||'-') : '-');

      $rows.eq(1).find('td.leader.point').text(t ? (t.LEADER_PRICE||t.LEADER_POINT||'-') : '-');
      $rows.eq(2).find('td.leader.tier').text(t ? (t.LEADER_TIER||'-') : '-');
      $rows.eq(3).find('td.leader.pos').text(t ? (t.LEADER_MROLE||t.LEADER_POS||'-') : '-');

      var tid = t && (t.TEAM_ID != null) ? String(t.TEAM_ID) : null;
      var ml  = (tid && membersByTeam && membersByTeam[tid]) ? membersByTeam[tid] : [];
      for (var s=1; s<=4; s++){
        var m = ml[s-1] || null;
        $rows.eq(0).find('td.m'+s+'.nick').text(m && m.NICK ? m.NICK : '-');
        $rows.eq(1).find('td.m'+s+'.point').text(m && (m.PRICE!=null) ? m.PRICE : '-');
        $rows.eq(2).find('td.m'+s+'.tier').text(m && m.TIER ? m.TIER : '-');
        var pos = m ? (m.MROLE || m.SROLE || m.POS) : null;
        $rows.eq(3).find('td.m'+s+'.pos').text(pos ? pos : '-');
      }

      $rows.eq(0).find('td.sec').text('닉네임');
    }

    G.teamRowById = {};
    G.leaderNickByTeamId = {};
    G.myTeamId = null;
    for (var i=1;i<=8;i++){
      var t = teams[i-1] || null;
      if (t && typeof t.TEAM_ID !== 'undefined') {
        var tid = String(t.TEAM_ID);
        G.teamRowById[tid] = i;
        G.leaderNickByTeamId[tid] = String(t.LEADER_NICK || "-");
        if (String(t.LEADER_NICK) === String(G.nick)) G.myTeamId = t.TEAM_ID;
      }
    }
  }

  function renderPlayerTable(players, membersByTeam){
    var soldByNick = {};
    if (membersByTeam) {
      Object.keys(membersByTeam).forEach(function(tid){
        (membersByTeam[tid]||[]).forEach(function(m){
          if (m && m.NICK) soldByNick[String(m.NICK)] = m;
        });
      });
    }
    for (var i=1;i<=40;i++){
      var p = players[i-1] || null;
      var $tr = $('#playerBody').find('tr[data-row="'+i+'"]');
      if (p){
        $tr.find('td').eq(0).text(i);
        $tr.find('td').eq(1).text(p.NICK || '-');
        $tr.find('td').eq(2).text(p.TIER || '-');
        $tr.find('td').eq(3).text(p.MROLE || '-');
        $tr.find('td').eq(4).text(p.SROLE || '-');
        var sold = p.NICK && soldByNick[p.NICK];
        $tr.find('td').eq(5).text(sold ? (sold.PRICE!=null ? sold.PRICE : '-') : '-');
        $tr.toggleClass('sold', !!sold).toggleClass('won', !!sold).removeClass('leading current');
      } else {
        $tr.find('td').eq(0).text(i);
        $tr.find('td').eq(1).text('-');
        $tr.find('td').eq(2).text('-');
        $tr.find('td').eq(3).text('-');
        $tr.find('td').eq(4).text('-');
        $tr.find('td').eq(5).text('-');
        $tr.removeClass('sold won leading current');
      }
    }
  }

  function clearActiveFocus(){
    try{
      var ae = document.activeElement;
      if (ae && typeof ae.blur === 'function') ae.blur();
    }catch(e){}
  }

  $(document).on('click', '#btnBegin', function(){
    if (!G.code) { alert('세션 없음'); return; }
    var pid = $(this).data('pickid');
    if (!pid) { prepareRound(); return; }
    if (!confirm('해당 선수 경매를 시작하시겠습니까?')) return;

    $.ajax({
      url: URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + pid + "/begin",
      type: "POST",
      contentType: "application/json; charset=UTF-8",
      data: "{}"
    }).done(function(res){
      if (res && res.success===true && res.data){
        updateAuctionConsole(res.data);
      } else {
        alert((res && res.error && res.error.msg) ? res.error.msg : "시작 실패");
      }
    }).fail(function(){ alert("요청 실패"); });
  });

  function subscribeAuction(){
    if(!STOMP || !STOMP.connected || !G.aucSeq) return;
    if(STOMP_AUC_SUB){ try{ STOMP_AUC_SUB.unsubscribe(); }catch(e){} STOMP_AUC_SUB=null; }
    STOMP_AUC_SUB = STOMP.subscribe("/topic/auc."+G.aucSeq+".state", function(frame){
      try {
        var msg = JSON.parse(frame.body||"{}");
        updateAuctionConsole(msg);
      } catch(e){}
    });
  }

  function setCountdown(deadlineTs){
    if (typeof deadlineTs !== 'number') return;
    if (CNT_TIMER) { clearInterval(CNT_TIMER); CNT_TIMER=null; }
    function tick(){
      var leftMs = Math.max(0, deadlineTs - Date.now());
      var left = Math.ceil(leftMs/1000);
      var $cd = $("#countdown");
      $cd.text(left);
      if (left <= 5) { $cd.css({color:'#ff4d4d','font-weight':'800'}); }
      else { $cd.css({color:'', 'font-weight':''}); }
      if (left <= 0) { clearInterval(CNT_TIMER); CNT_TIMER=null; }
    }
    tick();
    CNT_TIMER = setInterval(tick, 200);
  }

  function highlightCurrentByNick(nick){
    $("#playerTable tr.current").removeClass("current");
    if (!nick) return false;
    var found = false;
    $("#playerBody tr").each(function(){
      if ($(this).find('td').eq(1).text().trim() === String(nick).trim()) {
        $(this).addClass("current");
        try { this.scrollIntoView({behavior:'smooth', block:'center'}); } catch(e){}
        found = true;
        return false;
      }
    });
    return found;
  }

  function toggleControlsFromResp(r){
    if (!r || r.success!==true) return;
    var c = r.data || {};
    var canBid = (c.canBid !== false);

    $("#btnBid").prop("disabled", !canBid);
    $("#bidAmount").prop("disabled", !canBid);
    // 스텝버튼 일괄 토글
    $(".step-buttons .btn.step").prop("disabled", !canBid);
	$("#btnAllinQuick").prop("disabled", !canBid || !c.canAllin);
    // 그리드 컨테이너에 상태 표시(선택)
    $(".controls-grid").toggleClass("is-disabled", !canBid);

    if (!canBid) {
      $(".hint").text("팀 정원 5명 완료");
      AUC_NEXT_MIN = null; AUC_GRACE = false;
      return;
    }

    if (typeof c.nextMin === 'number') {
      AUC_NEXT_MIN = c.nextMin;
      $("#bidAmount")
        .attr("min", c.nextMin)
        .attr("step", 10)
        .attr("placeholder", c.nextMin + " 이상 (10 단위)");
    } else {
      AUC_NEXT_MIN = null;
    }
    AUC_GRACE = !!c.grace;

    $(".hint").text("경매 최소 단위 : ~100:+10 / 100~400:+20 / 400~:+50 (모든 입찰 10단위)");
  }

  function updateAuctionConsole(s){
	  if (!s) return;

	  var DID_PRICE_UPDATE = false;
	  var DID_BIDDER_UPDATE = false;

	  // 픽 종료(성공/유찰/재큐) 공통 처리
	  if (s.assigned === true || s.assigned === false || s.requeued === true) {
	    $("#playerBody tr").removeClass("leading current");
	    if (!DID_BIDDER_UPDATE) { $("#bidStatus").text("-"); }

	    // ★ 유찰(assigned=false) 또는 requeued 때는 리스트 '낙찰' 칸을 '-'로 되돌린다
	    if ((s.assigned === false || s.assigned === "false" || s.requeued === true || s.requeued === "true") && s.targetNick) {
		  $("#playerBody tr").each(function(){
		    var $tr  = $(this);
		    var $tds = $tr.find("td");
		    if ($tds.eq(1).text().trim() === String(s.targetNick).trim()) {
		      $tds.eq(5).text('-');
		      $tr.removeClass('leading');
		
		      var requeued       = (s.requeued === true || s.requeued === "true");
		      var assignedFalse  = (s.assigned === false || s.assigned === "false");
		
		      if (requeued) {
		        $tr.removeClass('unsold');   // 재큐이면 유찰표시 제거
		      } else if (assignedFalse) {
		        $tr.addClass('unsold');      // 진짜 유찰이면 표시
		      }
		      return false;
		    }
		  });
		}
	  }

	  // 새 픽 진입 시 콘솔 상태 초기화 (리스트 가격칸은 건드리지 않음)
	  if (s.pickId && s.pickId !== LAST_PICK_ID) {
	    LAST_PICK_ID = s.pickId;
	    G.currentPickId = s.pickId;
	    clearBidInput();
	    $("#currentPrice").text(0);
	    $("#playerBody tr").removeClass("leading current");
	    $("#myBudgetHold").text("");
	    $("#btnBegin").removeData('pickid').prop('disabled', true);
	    $("#bidStatus").text("-");
	  }

	  if (typeof s.targetNick === 'string') { $("#currentTarget").text(s.targetNick); }

	  if (typeof s.highestBid === 'number') {
	    var $price = $("#currentPrice");
	    var prev = auToInt($price.text());
	    var next = auToInt(s.highestBid);
	    if (next !== prev) {
	      $price.text(next);
	      var raf = window.requestAnimationFrame || function(fn){ return setTimeout(fn, 0); };
	      raf(function(){ fxBump($price); });
	      DID_PRICE_UPDATE = true;
	    }
	  }

	  if (typeof s.deadlineTs === 'number') { setCountdown(s.deadlineTs); }
	  if (typeof s.targetNick === 'string' && !s.assigned) { highlightCurrentByNick(s.targetNick); }

	  // ★ 진행 중 테이블 업데이트: 첫 입찰 전(highestBid==0)이면 '-' 유지 (0을 쓰지 않음)
	  if (s.targetNick && typeof s.highestBid === 'number' && !s.assigned) {
	    $("#playerBody tr").each(function(){
	      var $tr = $(this);
	      var $tds = $tr.find("td");
	      var isTarget = ($tds.eq(1).text().trim() === String(s.targetNick).trim());
	      if (isTarget) {
	        if (!$tr.hasClass('sold')) {
	          if (s.highestBid > 0) {
	            $tds.eq(5).text(s.highestBid);
	            $tr.addClass("leading");
	          } else {
	            // 첫 입찰 전: 가격 칸을 '-'로 유지하고 leading 제거
	            $tds.eq(5).text('-');
	            $tr.removeClass("leading");
	          }
	        }
	      } else {
	        $tr.removeClass("leading");
	      }
	    });
	  }

	  // 내 팀의 홀드 금액 표시
	  if (G.myTeamId && s.highestTeam && typeof s.highestBid === 'number') {
	    if (String(G.myTeamId) === String(s.highestTeam)) {
	      var currentLeft = parseInt($("#myBudget").text()||"0",10);
	      $("#myBudgetHold").text("잔여 : " + Math.max(0, currentLeft - s.highestBid));
	    } else {
	      $("#myBudgetHold").text("");
	    }
	  }

	  // 현재 최고 입찰 팀(닉) 표시
	  if (!s.assigned && s.highestTeam) {
	    var leader = G.leaderNickByTeamId && G.leaderNickByTeamId[String(s.highestTeam)];
	    var $bs = $("#bidStatus");
	    var prevTxt = $.trim($bs.text());
	    var nextTxt = leader || "-";
	    if (nextTxt !== prevTxt) {
	      $bs.text(nextTxt);
	      DID_BIDDER_UPDATE = true;
	      var raf2 = window.requestAnimationFrame || function(fn){ return setTimeout(fn, 0); };
	      raf2(function(){ fxBump($bs); });
	    }
	  }

	  // 낙찰 처리(가격 확정)
	  if (s.assigned === true) {
	    $("#myBudgetHold").text("");
	    if (s.targetNick) {
	      $("#playerBody tr").each(function(){
	        var $tds = $(this).find("td");
	        if ($tds.eq(1).text().trim() === String(s.targetNick).trim()) {
	        	$tds.eq(5).text(s.price != null ? s.price : "-");
	        	$(this).addClass("sold won").removeClass("unsold");
	          return false;
	        }
	      });
	    }
	    var applied = applyAssignmentToTeamSheet(s);
	    if (!applied) { PENDING_ASSIGN = s; setTimeout(loadTeamSheetOnly, 350); }
	  }

	  // 컨트롤 토글
	  if (s.pickId && !s.assigned && (G.role === 'ADMIN_GHOST' || G.role === 'LEADER')) {
	    $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + s.pickId + "/controls")
	      .done(toggleControlsFromResp);
	  } else {
		$("#btnBid, #bidAmount").prop("disabled", true);
		$(".step-buttons .btn.step").prop("disabled", true);
		$("#btnBid, #bidAmount, #btnAllinQuick").prop("disabled", true);
		$(".step-buttons .btn.step").prop("disabled", true);
		$(".controls-grid").addClass("is-disabled");
		$(".hint").text("관리자 모드");
	  }

	  // 대기(다음 픽 준비) 상태
	  if (!s.pickId && (s.waiting === true || s.waitingPickId != null || (s.nextPickId && !s.deadlineTs))) {
	    G.currentPickId = null;
	    $("#playerBody tr").removeClass("leading current");
	    if (!DID_PRICE_UPDATE) { $("#currentPrice").text(0); }
	    $("#bidAmount").val("");
	    $("#myBudgetHold").text("");
	    $("#countdown").text("--").css({color:'', 'font-weight':''});
	    $("#bidStatus").text("-");
	    var nextNick = s.nextTarget || s.targetNick || "-";
	    $("#currentTarget").text(String(nextNick||"-"));
	    highlightCurrentByNick(nextNick);
	    var pid = s.waitingPickId || s.nextPickId || null;
	    if (!nextNick || nextNick === '-' || !pid) {
	      $("#btnBegin").data('pickid', null).prop('disabled', true);
	    } else {
	      $("#btnBegin").data('pickid', pid).prop('disabled', !pid);
	    }
	    return;
	  }

	  if (s.finished === true || s.auctionEnd === true) { setStep("STEP4"); return; }
	}
	  

  $(document).on("click", "#btnBid", function(){
	  if (!G.code) { alertAndClear("세션 없음"); return; }
	  if (!G.currentPickId) { alertAndClear("입찰 진행중인 건이 없습니다."); return; }

	  var current = parseInt($("#currentPrice").text()||"0",10);
	  var raw = $("#bidAmount").val();

	  if (raw === "" || raw == null) { alertAndClear("금액을 입력하세요."); return; }

	  var amount = parseInt(raw,10);
	  if (isNaN(amount)) { alertAndClear("숫자만 입력하세요."); return; }
	  if (amount < 10 || (amount % 10) !== 0) {
	    alertAndClear("입찰 금액은 10 단위여야 합니다. (예: 10, 20, 30 …)");
	    return;
	  }
	  if (amount <= current) { alertAndClear("현재 경매가보다 큰 금액을 입력하세요."); return; }
	  if (AUC_NEXT_MIN != null && amount < AUC_NEXT_MIN) {
	    alertAndClear("최소 입찰 금액은 " + AUC_NEXT_MIN + " 입니다.");
	    return;
	  }

	  var $btn = $(this).prop("disabled", true).text("전송중…");
	  $.ajax({
	    url: URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + G.currentPickId + "/bid",
	    type: "POST",
	    contentType: "application/json; charset=UTF-8",
	    data: JSON.stringify({ amount: amount })
	  }).done(function(res){
	    if (!res || res.success!==true){
	      var msg = (res && res.error && res.error.msg) ? res.error.msg : "입찰 실패";
	      alertAndClear(msg); // 서버 실패도 비움
	    } else {
	      $(".hint").text("입찰 요청 완료! 서버 반영 중…");
	    }
	  }).fail(function(xhr){
	    alertAndClear("네트워크 오류로 입찰 실패" + (xhr && xhr.status ? " ("+xhr.status+")" : ""));
	  }).always(function(){
	    $btn.prop("disabled", false).text("입찰");
	    // 성공/실패 무관하게 비우기(성공 시에도 빈칸 유지해서 힌트 보이게)
	    clearBidInput();
	  });
	});

  $(document).on("change", "#bidAmount", function(){
	  var raw = $(this).val();
	  if (raw === "" || raw == null) {
	    this.setCustomValidity("");
	    return;
	  }
	  var v = parseInt(raw, 10);
	  if (isNaN(v) || v < 10 || (v % 10)!==0) {
	    this.setCustomValidity("입찰 금액은 10 단위여야 합니다. (1~9 불가)");
	  } else {
	    this.setCustomValidity("");
	  }
  });

  function loadTeamSheetOnly() {
    if (!G.code) return;
    $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/step3/snapshot")
      .done(function(res){
        if(!res || res.success!==true){ return; }
        var data = res.data || {};
        renderTeamSheet(data.teams || [], data.teamMembers || {});
        if (PENDING_ASSIGN) {
          applyAssignmentToTeamSheet(PENDING_ASSIGN);
          PENDING_ASSIGN = null;
        }
      });
  }

  function syncState(){
    if (!G.code) return;
    $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/state")
      .done(function(res){
        if (res && res.success===true && res.data){
          updateAuctionConsole(res.data);
        }
      });
  }

  function applyAssignmentToTeamSheet(assign){
    if (!assign || !assign.teamId) return false;
    var tid = String(assign.teamId);
    var rowIdx = G.teamRowById && G.teamRowById[tid];
    if (!rowIdx) return false;

    var $rows = $('#teamSheetBody').find('tr[data-team="'+rowIdx+'"]');

    if (typeof assign.teamBudgetLeft === 'number') {
      var init = parseInt($rows.eq(0).find('td.init').text()||"0", 10);
      var left = assign.teamBudgetLeft;
      $rows.eq(0).find('td.left').text(left);
      $rows.eq(0).find('td.used').text(Math.max(0, init - left));
      if (G.myTeamId && String(G.myTeamId) === tid) {
        $("#myBudget").text(left);
        $("#myBudgetHold").text("");
      }
    }

    var slot = null;
    for (var s=1; s<=4; s++){
      var $nickCell = $rows.eq(0).find('td.m'+s+'.nick');
      var nickText = ($nickCell.text()||'').trim();
      if (!nickText || nickText === '-') { slot = s; break; }
    }
    if (!slot) return true;

    var member = {
      nick:  assign.targetNick || '-',
      price: assign.price != null ? assign.price : '-',
      tier:  assign.targetTier  || '-',
      pos:   assign.targetMrole || assign.targetSrole || assign.pos || '-'
    };

    $rows.eq(0).find('td.m'+slot+'.nick').text(member.nick);
    $rows.eq(1).find('td.m'+slot+'.point').text(member.price);
    $rows.eq(2).find('td.m'+slot+'.tier').text(member.tier);
    $rows.eq(3).find('td.m'+slot+'.pos').text(member.pos);

    return true;
  }

  function auToInt(x){
    try { return parseInt(String(x).replace(/[^0-9\-]/g, ''), 10) || 0; }
    catch (e){ return 0; }
  }

  var FX_CONF = { bumpMs: 520, glowMs: 720, sweepMs: 900, scale: 1.25 };

  function fxBump($el){
    if (!$el || !$el.length) return;
    var el = $el[0];
    if (el && typeof el.animate === 'function') {
      try { if (typeof el.getAnimations === 'function') { var arr = el.getAnimations(); for (var i=0;i<arr.length;i++){ try{ arr[i].cancel(); }catch(_e){} } } } catch (_e2) {}
      var origColor = ''; try { var cs = window.getComputedStyle ? getComputedStyle(el) : null; origColor = cs ? cs.color : ''; } catch(_e3){}
      el.animate([
        { transform:'scale(1)', textShadow:'none', color: origColor },
        { transform:'scale(' + FX_CONF.scale + ')', textShadow:'0 0 10px rgba(255,213,77,.55), 0 0 18px rgba(255,213,77,.35)', color:'#ffe27a' },
        { transform:'scale(1)', textShadow:'none', color: origColor }
      ], { duration: FX_CONF.bumpMs, easing:'cubic-bezier(.2,.9,.2,1)', fill:'none' });
      try {
        var bar = document.createElement('span');
        bar.style.position = 'absolute';
        bar.style.left = '0'; bar.style.top = '50%';
        bar.style.width = '100%'; bar.style.height = '40%';
        bar.style.transform = 'translate(-120%, -50%)';
        bar.style.borderRadius = '8px';
        bar.style.background = 'linear-gradient(90deg, transparent, rgba(255,213,77,.28), transparent)';
        bar.style.pointerEvents = 'none'; bar.style.opacity = '0';
        el.appendChild(bar);
        bar.animate([
          { transform:'translate(-120%, -50%)', opacity:0.0 },
          { transform:'translate(0%, -50%)', opacity:0.35, offset:0.18 },
          { transform:'translate(220%, -50%)', opacity:0.0 }
        ], { duration: FX_CONF.sweepMs, easing:'ease-out', fill:'forwards' });
        setTimeout(function(){ try { if (bar && bar.parentNode) bar.parentNode.removeChild(bar); } catch(e){} }, FX_CONF.sweepMs + 40);
      } catch(_e4){}
      return;
    }
    try {
      el.className = el.className.replace(/\bau-bump-strong\b/g, '').replace(/\bau-glow\b/g, '').replace(/\bau-sweep\b/g, '').replace(/\s{2,}/g, ' ').replace(/^\s+|\s+$/g, '');
      el.offsetWidth;
      el.style.animationDuration = FX_CONF.bumpMs + 'ms';
      el.className += (el.className ? ' ' : '') + 'au-bump-strong au-glow au-sweep';
      setTimeout(function(){
        try {
          el.className = el.className.replace(/\bau-bump-strong\b/g, '').replace(/\bau-glow\b/g, '').replace(/\bau-sweep\b/g, '').replace(/\s{2,}/g, ' ').replace(/^\s+|\s+$/g, '');
          el.style.animationDuration = '';
        } catch(e){}
      }, Math.max(FX_CONF.bumpMs, FX_CONF.sweepMs) + 40);
    } catch(e){}
  }

  function loadStep4(){
    if (!G.code) return;
    $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/step3/snapshot")
      .done(function(res){
        if (!res || res.success !== true) return;
        var d = res.data || {};
        renderTeamSheetTo("finalTeamSheetBody", d.teams || [], d.teamMembers || {});
      });
  }

  $(document).on('click', '#btnBackToLobby', function(){
    function clearAndReload(){
      try{
        sessionStorage.removeItem("auc.last");
        sessionStorage.removeItem("auc.reloading");
        sessionStorage.removeItem("auc.role");
      }catch(e){}
      location.reload();
    }
    if (G.code) {
      $.ajax({
        url: URLS.auctionBase + encodeURIComponent(G.code) + "/lobby/exit",
        type: "POST",
        contentType: "application/json; charset=UTF-8",
        data: "{}"
      }).always(clearAndReload);
    } else {
      clearAndReload();
    }
  });

  function renderTeamSheetTo(tbodyId, teams, membersByTeam){
    for (var i=1;i<=8;i++){
      var t = teams[i-1] || null;
      var $rows = $('#'+tbodyId).find('tr[data-team="'+i+'"]');

      var budget = t ? (t.BUDGET||0) : 0;
      var left   = t ? (t.BUDGET_LEFT||0) : 0;
      var used   = t ? (t.USED||Math.max(0, budget - left)) : 0;

      $rows.eq(0).find('td.init').text(budget);
      $rows.eq(0).find('td.used').text(used);
      $rows.eq(0).find('td.left').text(left);
      $rows.eq(0).find('td.leader.nick').text(t ? (t.LEADER_NICK||'-') : '-');

      $rows.eq(1).find('td.leader.point').text(t ? (t.LEADER_PRICE||t.LEADER_POINT||'-') : '-');
      $rows.eq(2).find('td.leader.tier').text(t ? (t.LEADER_TIER||'-') : '-');
      $rows.eq(3).find('td.leader.pos').text(t ? (t.LEADER_MROLE||t.LEADER_POS||'-') : '-');

      var tid = t && (t.TEAM_ID != null) ? String(t.TEAM_ID) : null;
      var ml  = (tid && membersByTeam && membersByTeam[tid]) ? membersByTeam[tid] : [];
      for (var s=1; s<=4; s++){
        var m = ml[s-1] || null;
        $rows.eq(0).find('td.m'+s+'.nick').text(m && m.NICK ? m.NICK : '-');
        $rows.eq(1).find('td.m'+s+'.point').text(m && (m.PRICE!=null) ? m.PRICE : '-');
        $rows.eq(2).find('td.m'+s+'.tier').text(m && m.TIER ? m.TIER : '-');
        var pos = m ? (m.MROLE || m.SROLE || m.POS) : null;
        $rows.eq(3).find('td.m'+s+'.pos').text(pos ? pos : '-');
      }

      $rows.eq(0).find('td.sec').text('닉네임');
    }
  }

  function clearBidInput(){
	  var $in = $("#bidAmount");
	  $in.val("");                  // 값 비움 → placeholder 노출
	  $in[0]?.setCustomValidity(""); // 커스텀 에러 초기화
	}

	$(document).on("keydown", "#bidAmount", function(e){
	  if(e.key === "Enter"){ $("#btnBid").click(); }
	});

	$("#bidAmount").on("wheel", e => e.preventDefault());

	// 공통: 알림 + 입력칸 비우기 + 포커스
	function alertAndClear(msg){
	  alert(msg);
	  clearBidInput();
	  $("#bidAmount").focus();
	}

	// +10 / +20 / +50 스텝 버튼
	$(document).on("click", ".step-buttons .btn.step", function(){
	  var step = parseInt($(this).data("step"), 10) || 0;
	  var $in = $("#bidAmount");
	  var curIn     = parseInt($in.val(), 10);
	  var curPrice  = parseInt($("#currentPrice").text() || "0", 10);
	  var base      = isNaN(curIn) ? curPrice : curIn;   // ← 입력 비면 '현재가' 기준
	  var next      = base + step;

	  // 10단위로 스냅
	  if (next % 10 !== 0) next = Math.ceil(next / 10) * 10;

	  // 서버 최소 입찰(nextMin) 보장
	  if (AUC_NEXT_MIN != null && next < AUC_NEXT_MIN) next = AUC_NEXT_MIN;

	  $in.val(next).trigger("change").focus();
	});
	
	// 올인(입력칸만 채우기) - 현재가/최소입찰/AUC_GRACE 고려, 잔액 초과하지 않음
	$(document).on("click", "#btnAllinQuick", function(){
	  var $in = $("#bidAmount");
	  var curIn     = parseInt($in.val(), 10);
	  var current   = parseInt($("#currentPrice").text() || "0", 10) || 0;
	  var nextMin   = (typeof AUC_NEXT_MIN === "number") ? AUC_NEXT_MIN : (current + 10);
	  var myLeft    = parseInt($("#myBudget").text() || "0", 10) || 0;

	  // 기준값: 입력칸 있으면 그 값, 없으면 현재가/최소입찰 기준
	  var base = isNaN(curIn) ? Math.max(current + 10, nextMin) : Math.max(curIn, nextMin);
	  var target = Math.min(myLeft, base);

	  // 10단위 보정
	  if (target % 10 !== 0) target += (10 - (target % 10));
	  $in.val(target).trigger("change");
	});
	
})(window.jQuery || window.$);
</script>