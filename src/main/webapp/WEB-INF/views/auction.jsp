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
        <h3>입찰 콘솔</h3>
        <div class="console">
			<div class="kv-row">
			  <div class="kv"><span class="k">현재가</span><span class="v" id="currentPrice">0</span></div>
			  <div class="kv"><span class="k">남은시간</span><span class="v" id="countdown">--</span></div>
			  <div class="kv"><span class="k">내 잔액</span><span class="v" id="myBudget">0</span></div>
			</div>
			<div class="row top controls">
			  <div class="ig">
			    <input type="number" id="bidAmount" min="0" step="10" class="input-number"/>
			    <button class="btn primary" id="btnBid">입찰</button>
			    <button class="btn danger" id="btnAllin">올인</button>
			  </div>
			</div>
			<div class="row sm quickline">
			  <button class="btn sm" data-inc="10" type="button">+10</button>
			  <button class="btn sm" data-inc="20" type="button">+20</button>
			  <button class="btn sm" data-inc="50" type="button">+50</button>
			</div>
			<div class="hint">입찰 단위: 10~100 +10 / 100~400 +20 / 400이상 +50</div>
			<div class="err" id="bidErr" hidden></div>
        </div>

        <h3 style="margin-top:14px">경매 선수 리스트</h3>
        <div class="tbl-scroll tall players">
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
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<link rel="stylesheet" href="<c:url value='/resources/css/auction.css'/>">

<style>
  body.admin #btnReady { display: none !important; }
</style>

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>

<script>var CTX = "<c:url value='/'/>";</script>

<script>
(function($){
  "use strict";

  var URLS = {
    ws: "<c:url value='/ws-auction'/>",
    restore: "<c:url value='/api/auction/restore'/>",
    auctionBase: "<c:url value='/api/auction/'/>"
  };

  var STOMP=null, STOMP_SUB=null, RECONNECT_TIMER=null, RECONNECT_WAIT=300, MAX_WAIT=5000;
  var G={ code:null, aucSeq:null, nick:null, role:null };

  window.addEventListener("pagehide", function(){
    try { sessionStorage.setItem("auc.reloading","1"); } catch(e){}
  });

  function setStep(step){
    $("#auctionApp").attr("data-state", step);
    document.body.setAttribute("data-state", step);
    $(".step").hide();
    if(step==="STEP1") $("#step1").show();
    if(step==="STEP2") $("#step2").show();
    if(step==="STEP3") $("#step3").show();
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
    $btn
      .text(isReady ? "준비 해제" : "준비 완료")
      .data("ready", isReady)
      .attr("aria-pressed", isReady ? "true" : "false")
      .toggleClass("outline", isReady)
      .prop("disabled", !isOnline)
      .attr("title", isOnline ? "" : "오프라인 상태에서는 변경할 수 없습니다.");
  }

  function subscribeLobby(){
    if(!STOMP || !STOMP.connected || !G.aucSeq) return;
    if(STOMP_SUB) { try{ STOMP_SUB.unsubscribe(); }catch(e){} STOMP_SUB=null; }
    STOMP_SUB = STOMP.subscribe("/topic/lobby."+G.aucSeq, function(frame){
      try { var msg = JSON.parse(frame.body||"{}");  if (msg && msg.status === 'ING') { setStep('STEP3'); return; }renderLobby(msg); } catch(e){}
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
    }, function(){
      scheduleReconnect();
    });
  }

  function disconnectStomp(){
    if(STOMP){
      try{ if(STOMP_SUB) STOMP_SUB.unsubscribe(); }catch(e){}
      try{ STOMP.disconnect(function(){}); }catch(e){}
    }
    STOMP=null; STOMP_SUB=null;
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
      const data = snap && snap.data || {};
      renderLobby(data);
      const st = data.status || "WAIT";
      setStep(st==="ING" ? "STEP3" : "STEP2");
      G.code = code; G.aucSeq = data.aucSeq || G.aucSeq;
      connectStomp();
    }).fail(function(){
      setStep("STEP2");
      connectStomp();
    });
  }

  $("#btnJoin").on("click", function(){
    const code = ($("#code").val()||"").trim();
    const nick = ($("#nick").val()||"").trim();
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
    var dest = isReady
      ? ("/app/lobby."+G.aucSeq+".unready")
      : ("/app/lobby."+G.aucSeq+".ready");
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
		    if (r && r.success) {
		    } else {
		      alert(r && r.error ? r.error.msg : '시작 실패');
		    }
		  }).fail(function(){
		    alert('시작 요청 오류');
		  });
  });

  function tryRestore(){
    var isReload = false;
    try { isReload = sessionStorage.getItem("auc.reloading")==="1"; } catch(e){}
    let cached=null; try{ cached = JSON.parse(sessionStorage.getItem("auc.last")||"null"); }catch(e){}

    try {
      var savedRole = sessionStorage.getItem("auc.role");
      if (savedRole === 'ADMIN_GHOST') { document.body.classList.add('admin'); G.role = savedRole; }
    } catch(e){}

    if(isReload && cached && cached.code && cached.nick){
      try{ sessionStorage.removeItem("auc.reloading"); }catch(e){}
      $.ajax({
        url: URLS.auctionBase + encodeURIComponent(cached.code) + "/lobby/join",
        type: "POST",
        contentType: "application/json; charset=UTF-8",
        data: JSON.stringify({ code: cached.code, nick: cached.nick })
      }).done(function(res2){
        if(res2 && res2.success===true){ G.nick=cached.nick; afterJoin(cached.code); }
        else setStep("STEP1");
      }).fail(function(){ setStep("STEP1"); });
      return;
    }

    $.getJSON(URLS.restore).done(function(res){
      const data = res && res.data;
      if (res && res.success===true && data){
        renderLobby(data);
        setStep((data.status==="ING") ? "STEP3" : "STEP2");
        G.aucSeq = data.aucSeq; G.code = data.code; G.nick = data.nick;
        connectStomp();
      } else if(cached && cached.code && cached.nick){
        $.ajax({
          url: URLS.auctionBase + encodeURIComponent(cached.code) + "/lobby/join",
          type: "POST",
          contentType: "application/json; charset=UTF-8",
          data: JSON.stringify({ code: cached.code, nick: cached.nick })
        }).done(function(res2){
          if(res2 && res2.success===true){ G.nick=cached.nick; afterJoin(cached.code); }
          else setStep("STEP1");
        }).fail(function(){ setStep("STEP1"); });
      } else {
        setStep("STEP1");
      }
    }).fail(function(){
      if(cached && cached.code && cached.nick){
        $.ajax({
          url: URLS.auctionBase + encodeURIComponent(cached.code) + "/lobby/join",
          type: "POST",
          contentType: "application/json; charset=UTF-8",
          data: JSON.stringify({ code: cached.code, nick: cached.nick })
        }).done(function(res2){
          if(res2 && res2.success===true){ G.nick=cached.nick; afterJoin(cached.code); }
          else setStep("STEP1");
        }).fail(function(){ setStep("STEP1"); });
      } else {
        setStep("STEP1"); 
      }
    });
  }

  $(function(){ tryRestore(); });

})(window.jQuery || window.$);
</script>
