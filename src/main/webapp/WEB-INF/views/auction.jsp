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
        <h3>
          입찰 콘솔&nbsp;&nbsp;&nbsp;
          <button class="btn success sm" id="btnBegin" data-admin-only="true">경매 라운드 시작</button>
        </h3>
        <div class="console">
          <div class="kv-row">
            <div class="kv"><span class="k">대상</span><span class="v" id="currentTarget">-</span></div>
            <div class="kv"><span class="k">현재가</span><span class="v" id="currentPrice">0</span></div>
            <div class="kv"><span class="k">남은시간</span><span class="v" id="countdown">--</span></div>
            <div class="kv"><span class="k">내 잔액</span>
              <span class="v" id="myBudget">0</span>
              <span id="myBudgetHold" class="muted" style="margin-left:6px;"></span>
            </div>
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
          <div class="row sm quickline minusline">
            <button class="btn sm" data-inc="-10" type="button">-10</button>
            <button class="btn sm" data-inc="-20" type="button">-20</button>
            <button class="btn sm" data-inc="-50" type="button">-50</button>
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

<!-- 스타일: 낙찰 회색계열로 변경 -->
<style>
  #playerTable tr.current td{background:rgba(77,163,255,.12)}
  #playerTable tr.leading{opacity:.8}
  /* 🔁 회색계열 */
  #playerTable tr.sold td{background:rgba(150,155,165,.18)}
  #playerTable tr.won td{text-decoration:overline}
</style>

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>

<script>var CTX = "<c:url value='/'/>";</script>

<script>
(function($){
  "use strict";

  var STOMP=null, STOMP_SUB=null, STOMP_AUC_SUB=null;
  var RECONNECT_TIMER=null, RECONNECT_WAIT=300, MAX_WAIT=5000;
  var CNT_TIMER=null, LAST_PICK_ID=null;

  var URLS = {
    ws: "<c:url value='/ws-auction'/>",
    restore: "<c:url value='/api/auction/restore'/>",
    auctionBase: "<c:url value='/api/auction/'/>"
  };

  var G={ code:null, aucSeq:null, nick:null, role:null, currentPickId:null, teamRowById:null, myTeamId:null };
  var PENDING_HILITE = null;

  window.addEventListener("pagehide", function(){
    try { sessionStorage.setItem("auc.reloading","1"); } catch(e){}
  });

  function setStep(step){
    $("#auctionApp").attr("data-state", step);
    document.body.setAttribute("data-state", step);
    $(".step").hide();
    if(step==="STEP1") $("#step1").show();
    if(step==="STEP2") $("#step2").show();
    if(step==="STEP3"){
      $("#step3").show();
      if (G.code) loadStep3(); else setTimeout(function(){ if(G.code) loadStep3(); }, 120);
      if (STOMP && STOMP.connected) subscribeAuction();
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
    if(STOMP_SUB){ try{ STOMP_SUB.unsubscribe(); }catch(e){} STOMP_SUB=null; }
    STOMP_SUB = STOMP.subscribe("/topic/lobby."+G.aucSeq, function(frame){
      try {
        var msg = JSON.parse(frame.body||"{}");
        if (msg && msg.status === 'ING') { setStep('STEP3'); return; }
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
      const data = snap && snap.data || {};
      renderLobby(data);
      const st = data.status || "WAIT";
      G.code   = code;
      G.aucSeq = data.aucSeq || G.aucSeq;
      setStep(st==="ING" ? "STEP3" : "STEP2");
      if (st === "ING") { loadStep3(); }
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
      if (!(r && r.success)) {
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
        G.aucSeq = data.aucSeq;
        G.code   = data.code;
        G.nick   = data.nick;
        renderLobby(data);
        setStep((data.status==="ING") ? "STEP3" : "STEP2");
        if (data.status === "ING") { loadStep3(); }
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

  $(function(){
    tryRestore();
    $("#bidAmount").prop("readonly", true);
  });

  function loadStep3(){
    $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/step3/snapshot")
     .done(function(res){
       if(!res || res.success!==true){ alert(res && res.error ? res.error.msg : "스냅샷 실패"); return; }
       var data = res.data || {};
       renderTeamSheet(data.teams || []);
       renderPlayerTable(data.players || []);
       var me = (data.teams||[]).find(function(t){ return String(t.LEADER_NICK) === String(G.nick); });
       $("#myBudget").text(me ? (me.BUDGET_LEFT||0) : 0);
       $("#currentPrice").text(0);
       $("#countdown").text("--");
       $("#currentTarget").text("-");
       $("#bidAmount").val(0);

       if (PENDING_HILITE){
         highlightCurrentByNick(PENDING_HILITE);
         PENDING_HILITE = null;
       }
       if (G.currentPickId){
         $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + G.currentPickId + "/controls")
           .done(toggleControlsFromResp);
       }
     })
     .fail(function(xhr){ alert("스냅샷 호출 오류" + (xhr && xhr.status ? " ("+xhr.status+")" : "")); });
  }

  function renderTeamSheet(teams){
    for (var i=1;i<=8;i++){
      var t = teams[i-1] || null;
      var $rows = $('#teamSheetBody').find('tr[data-team="'+i+'"]');
      var budget = t ? (t.BUDGET||0) : 0;
      var left   = t ? (t.BUDGET_LEFT||0) : 0;
      var used   = t ? (t.USED||0) : 0;

      $rows.eq(0).find('td.init').text(budget);
      $rows.eq(0).find('td.used').text(used);
      $rows.eq(0).find('td.left').text(left);
      $rows.eq(0).find('td.leader.nick').text(t ? t.LEADER_NICK : '-');
      $rows.eq(0).find('td.m1.nick,td.m2.nick,td.m3.nick,td.m4.nick').text('-');

      $rows.eq(1).find('td.leader.point,td.m1.point,td.m2.point,td.m3.point,td.m4.point').text('-');

      $rows.eq(2).find('td.leader.tier').text(t ? (t.LEADER_TIER||'-') : '-');

      $rows.eq(3).find('td.leader.pos').text(t ? (t.LEADER_MROLE||'-') : '-');

      $rows.eq(0).find('td.sec').text('닉네임');
    }

    G.teamRowById = {};
    G.myTeamId = null;
    for (var i=1;i<=8;i++){
      var t = teams[i-1] || null;
      if (t && typeof t.TEAM_ID !== 'undefined') {
        G.teamRowById[String(t.TEAM_ID)] = i;
        if (String(t.LEADER_NICK) === String(G.nick)) G.myTeamId = t.TEAM_ID;
      }
    }
  }

  function renderPlayerTable(players){
    for (var i=1;i<=40;i++){
      var p = players[i-1] || null;
      var $tr = $('#playerBody').find('tr[data-row="'+i+'"]');
      if (p){
        $tr.find('td').eq(0).text(i);
        $tr.find('td').eq(1).text(p.NICK || '-');
        $tr.find('td').eq(2).text(p.TIER || '-');
        $tr.find('td').eq(3).text(p.MROLE || '-');
        $tr.find('td').eq(4).text(p.SROLE || '-');
        $tr.find('td').eq(5).text('-');
        $tr.removeClass('sold won leading current');
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

  // —— 유틸: 포커스 해제(다음 선수 전환 시 호출) ——
  function clearTableFocus(){
    try{
      var ae = document.activeElement;
      if (!ae) return;
      if ($(ae).closest('#playerPanel').length) { ae.blur(); }
    }catch(e){}
  }

  // 라운드 시작
  $(document).on('click', '#btnBegin', function(){
    if (!G.code) { alert('세션 없음'); return; }
    if (!confirm('경매를 시작하시겠습니까?')) return;

    $.ajax({
      url: URLS.auctionBase + encodeURIComponent(G.code) + "/step3/begin",
      type: "POST",
      contentType: "application/json; charset=UTF-8",
      data: "{}"
    }).done(function(res){
      if (!(res && res.success)) {
        alert(res && res.error ? res.error.msg : "시작 실패");
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
      $("#countdown").text(left);
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
    $(".quickline:not(.minusline) .btn").addClass("is-disabled").prop("disabled", true);
    (c.enabledIncs || []).forEach(function(x){
      $(".quickline:not(.minusline) .btn[data-inc='"+x+"']").removeClass("is-disabled").prop("disabled", false);
    });
    $(".minusline .btn").removeClass("is-disabled").prop("disabled", false);
    $("#btnAllin").prop("disabled", !c.canAllin);
  }

  function updateAuctionConsole(s){
    if (!s) return;

    // 새 pick 시작 감지 → 포커스 해제
    if (s.pickId && s.pickId !== LAST_PICK_ID) {
      LAST_PICK_ID = s.pickId;
      G.currentPickId = s.pickId;
      $("#bidAmount").val(0);
      $("#playerBody tr").removeClass("leading current");
      $("#myBudgetHold").text("");
      clearTableFocus(); /* ★ 포커스 해제 */
    }

    if (typeof s.targetNick === 'string') $("#currentTarget").text(s.targetNick);
    if (typeof s.highestBid === 'number') $("#currentPrice").text(s.highestBid);

    if (typeof s.deadlineTs === 'number') {
      setCountdown(s.deadlineTs);
    }

    if (typeof s.targetNick === 'string' && !s.assigned) {
      highlightCurrentByNick(s.targetNick);
    }

    if (s.targetNick && typeof s.highestBid === 'number' && !s.assigned) {
      $("#playerBody tr").each(function(){
        var $tr = $(this);
        var $tds = $tr.find("td");
        if ($tds.eq(1).text().trim() === String(s.targetNick).trim()) {
          $tds.eq(5).text(s.highestBid);
          $tr.addClass("leading");
        } else {
          $tr.removeClass("leading");
        }
      });
    }

    if (G.myTeamId && s.highestTeam && typeof s.highestBid === 'number') {
      if (String(G.myTeamId) === String(s.highestTeam)) {
        var currentLeft = parseInt($("#myBudget").text()||"0",10);
        $("#myBudgetHold").text("(가상: " + Math.max(0, currentLeft - s.highestBid) + ")");
      } else {
        $("#myBudgetHold").text("");
      }
    }

    if (s.assigned === true || s.assigned === false || s.requeued === true) {
      $("#playerBody tr").removeClass("leading current");
    }

    // ✅ 낙찰 확정: 좌측 팀시트 갱신(닉/가격/티어/주포지션)
    if (s.assigned === true) {
      if (!s.teamId || !s.targetNick) {
        PENDING_HILITE = null;
        loadStep3();
      } else {
        $("#playerBody tr").each(function(){
          var $tds = $(this).find("td");
          if ($tds.eq(1).text().trim() === String(s.targetNick).trim()) {
            $tds.eq(5).text(s.price != null ? s.price : "-");
            $(this).addClass("won sold");
            return false;
          }
        });

        var rowIdx = G.teamRowById ? G.teamRowById[String(s.teamId)] : null;
        if (rowIdx != null) {
          var $rows = $('#teamSheetBody').find('tr[data-team="'+rowIdx+'"]');
          var $nickCells = $rows.eq(0).find('td.m1.nick,td.m2.nick,td.m3.nick,td.m4.nick');
          var $pointCells= $rows.eq(1).find('td.m1.point,td.m2.point,td.m3.point,td.m4.point');
          var $tierCells = $rows.eq(2).find('td.m1.tier,td.m2.tier,td.m3.tier,td.m4.tier');       /* ★ 추가 */
          var $posCells  = $rows.eq(3).find('td.m1.pos,td.m2.pos,td.m3.pos,td.m4.pos');           /* ★ 추가 */
          for (var i=0;i<4;i++){
            if ($nickCells.eq(i).text().trim() === "-") {
              $nickCells.eq(i).text(s.targetNick);
              $pointCells.eq(i).text(s.price != null ? s.price : "-");
              $tierCells.eq(i).text(s.targetTier || "-");    /* ★ 티어 채우기 */
              $posCells.eq(i).text(s.targetMrole || "-");    /* ★ 주포지션 채우기 */
              break;
            }
          }
        }

        if (G.myTeamId && String(G.myTeamId) === String(s.teamId) && typeof s.teamBudgetLeft === 'number') {
          $("#myBudget").text(s.teamBudgetLeft);
          var rowIdx2 = G.teamRowById[String(G.myTeamId)];
          if (rowIdx2 != null) {
            var $rows2 = $('#teamSheetBody').find('tr[data-team="'+rowIdx2+'"]');
            var init = parseInt($rows2.eq(0).find('td.init').text()||"0",10);
            var left = s.teamBudgetLeft;
            var used = Math.max(0, init - left);
            $rows2.eq(0).find('td.left').text(left);
            $rows2.eq(0).find('td.used').text(used);
          }
        }
      }
      $("#myBudgetHold").text("");
    }

    // ===== 다음 타겟(다음 픽 오픈) 처리 =====
    if (s.nextPickId) {
      clearTableFocus(); /* ★ 다음 선수 전환 시 포커스 해제 */

      G.currentPickId = s.nextPickId;
      LAST_PICK_ID    = s.nextPickId;

      $("#currentPrice").text(0);
      $("#currentTarget").text(String(s.nextTarget||"-"));

      if (typeof s.deadlineTs === 'number') setCountdown(s.deadlineTs);

      var ok = highlightCurrentByNick(s.nextTarget);

      $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + s.nextPickId + "/controls")
        .done(toggleControlsFromResp);

      if (!ok) {
        PENDING_HILITE = s.nextTarget || null;
        loadStep3();
      }
      return;
    }

    if (s.pickId && !s.assigned) {
      $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + s.pickId + "/controls")
        .done(toggleControlsFromResp);
    }
  }

  $(document).on("click", ".quickline .btn", function(){
    var inc = parseInt($(this).data("inc"),10);
    if (isNaN(inc)) return;
    var base = parseInt($("#currentPrice").text()||"0",10);
    var now  = parseInt($("#bidAmount").val()||"0",10);
    if (!now || now < base) now = base;
    var next = now + inc;
    if (next < base) next = base;
    $("#bidAmount").val(next);
  });

  $(document).on("click", "#btnBid", function(){
    if (!G.code || !G.currentPickId) { alert("진행 중인 픽이 없습니다."); return; }
    var current = parseInt($("#currentPrice").text()||"0",10);
    var amount  = parseInt($("#bidAmount").val()||"0",10);
    if (isNaN(amount) || amount <= current) {
      $("#bidErr").text("현재가보다 큰 금액을 입력하세요.").show();
      return;
    }
    $("#bidErr").hide();
    var $btn = $(this).prop("disabled", true);
    $.ajax({
      url: URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + G.currentPickId + "/bid",
      type: "POST",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify({ amount: amount })
    }).done(function(res){
      if (!res || res.success!==true){
        $("#bidErr").text((res && res.error && res.error.msg) ? res.error.msg : "입찰 실패").show();
      }
    }).fail(function(){
      $("#bidErr").text("네트워크 오류로 입찰 실패").show();
    }).always(function(){
      $btn.prop("disabled", false);
    });
  });

  $(document).on("click", "#btnAllin", function(){
    if (!G.code || !G.currentPickId) { alert("진행 중인 픽이 없습니다."); return; }
    $("#bidErr").hide();
    var $btn = $(this).prop("disabled", true);
    $.ajax({
      url: URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + G.currentPickId + "/bid",
      type: "POST",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify({ allin: "Y" })
    }).done(function(res){
      if (!res || res.success!==true){
        $("#bidErr").text((res && res.error && res.error.msg) ? res.error.msg : "올인 실패").show();
      }
    }).fail(function(){
      $("#bidErr").text("네트워크 오류로 올인 실패").show();
    }).always(function(){
      $btn.prop("disabled", false);
    });
  });

})(window.jQuery || window.$);
</script>
