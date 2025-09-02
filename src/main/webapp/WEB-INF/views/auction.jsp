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
			  <div class="kv two-line">
			    <span class="k">현재 경매가</span>
			    <span class="v" id="currentPrice">0</span>
			  </div>
			  <div class="kv two-line">
			    <span class="k">현재 입찰자</span>
			    <span class="v" id="bidStatus">-</span>
			  </div>
			  <div class="kv two-line">
			    <span class="k">내 잔액</span>
			    <span class="v">
			      <span id="myBudget">0</span>
			      <span id="myBudgetHold" class="muted" style="margin-left:6px;"></span>
			    </span>
			  </div>
			  <div class="kv two-line">
			    <span class="k">남은 시간</span>
			    <span class="v" id="countdown">--</span>
			  </div>
			</div>
			<div class="row top controls">
			  <div class="ig">
			    <input type="number" id="bidAmount" min="0" step="10" class="input-number" placeholder="10 단위로 입력"/>
			    <button class="btn primary" id="btnBid">입찰</button>
			    <button class="btn danger" id="btnAllin">올인</button>
			  </div>
			</div>
			<div class="hint" aria-live="polite">경매 단위 :  ~100 : +10 / 100~400 : +20 / 400~ : +50</div>
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

  var URLS = {
    ws: "<c:url value='/ws-auction'/>",
    restore: "<c:url value='/api/auction/restore'/>",
    auctionBase: "<c:url value='/api/auction/'/>"
  };

  var G={ code:null, aucSeq:null, nick:null, role:null, currentPickId:null, teamRowById:null, myTeamId:null, leaderNickByTeamId:{} };
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
	    syncState();
	    if (G.code) loadStep3(); else setTimeout(function(){ if(G.code) loadStep3(); }, 120);
	    if (STOMP && STOMP.connected) subscribeAuction();
	    if (G.role === 'ADMIN_GHOST') prepareRound();
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
          var full = ml.length >= 4; // 리더 제외 4명
          $("#btnBid, #btnAllin, #bidAmount").prop("disabled", full);
          $(".controls .ig").toggleClass("is-disabled", full);
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
    $("#btnAllin").prop("disabled", !canBid || !c.canAllin);
    $(".controls .ig").toggleClass("is-disabled", !canBid);
    if (!canBid) {
    	$(".hint").text("팀 정원 5명 완료");
    } else {
    	$(".hint").text("경매 단위 :  ~100 : +10 / 100~400 : +20 / 400~ : +50");
    }
  }

  function updateAuctionConsole(s){
      if (!s) return;

  	if (s.idle === true || s.roundEnd === true) {
  	   $("#btnBegin").removeData('pickid').prop('disabled', true);
  	   $("#currentTarget").text("-");
  	   $("#currentPrice").text(0);
  	   $("#bidStatus").text("-");
  	   $("#countdown").text("--").css({color:'', 'font-weight':''});
  	   return;
  	}
  	
  	if (s.assigned === true || s.assigned === false || s.requeued === true) {
  		$("#playerBody tr").removeClass("leading current");
  		$("#bidStatus").text("-");
  	}
  	
      if (s.pickId && s.pickId !== LAST_PICK_ID) {
        LAST_PICK_ID = s.pickId;
        G.currentPickId = s.pickId;

        clearActiveFocus();
        $("#bidAmount").val(0);
        $("#currentPrice").text(0);
        $("#playerBody tr").removeClass("leading current");
        $("#myBudgetHold").text("");
        $("#btnBegin").removeData('pickid').prop('disabled', true);
        $("#bidStatus").text("-");
      }

      if (typeof s.targetNick === 'string') $("#currentTarget").text(s.targetNick);
      if (typeof s.highestBid === 'number') $("#currentPrice").text(s.highestBid);

      if (typeof s.deadlineTs === 'number') setCountdown(s.deadlineTs);

      if (typeof s.targetNick === 'string' && !s.assigned) {
        highlightCurrentByNick(s.targetNick);
      }

      if (s.targetNick && typeof s.highestBid === 'number' && !s.assigned) {
        $("#playerBody tr").each(function(){
          var $tr = $(this);
          var $tds = $tr.find("td");
          if ($tds.eq(1).text().trim() === String(s.targetNick).trim()) {
          	if (!$tr.hasClass('sold')) {
  	        	$tds.eq(5).text(s.highestBid);
  	        	$tr.addClass("leading");
          	}
          } else {
            $tr.removeClass("leading");
          }
        });
      }

      if (G.myTeamId && s.highestTeam && typeof s.highestBid === 'number') {
        if (String(G.myTeamId) === String(s.highestTeam)) {
          var currentLeft = parseInt($("#myBudget").text()||"0",10);
          $("#myBudgetHold").text("잔여 : " + Math.max(0, currentLeft - s.highestBid));
        } else {
          $("#myBudgetHold").text("");
        }
      }

      if (!s.assigned && s.highestTeam) {
      	  var leader = G.leaderNickByTeamId && G.leaderNickByTeamId[String(s.highestTeam)];
      	  $("#bidStatus").text(leader || "-");
      }

      if (s.assigned === true || s.assigned === false || s.requeued === true) {
        $("#playerBody tr").removeClass("leading current");
        $("#bidStatus").text("-");
      }

      if (s.assigned === true) {
        $("#myBudgetHold").text("");
        if (s.targetNick) {
          $("#playerBody tr").each(function(){
            var $tds = $(this).find("td");
            if ($tds.eq(1).text().trim() === String(s.targetNick).trim()) {
              $tds.eq(5).text(s.price != null ? s.price : "-");
  			$(this).addClass("sold won");
              return false;
            }
          });
        }
  	  applyAssignmentToTeamSheet(s);
      }

      if (s.pickId && !s.assigned) {
        $.getJSON(URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + s.pickId + "/controls")
          .done(toggleControlsFromResp);
      }
  	
  	if (!s.pickId && (s.waiting === true || s.waitingPickId != null || (s.nextPickId && !s.deadlineTs))) {
  	   G.currentPickId = null;
  	   $("#playerBody tr").removeClass("leading current");
  	   $("#currentPrice").text(0);
  	   $("#bidAmount").val(0);
  	   $("#myBudgetHold").text("");
  	   $("#countdown").text("--").css({color:'', 'font-weight':''});
  	   $("#bidStatus").text("-");
  	
  	   var nextNick = s.nextTarget || s.targetNick || "-";
  	   $("#currentTarget").text(String(nextNick||"-"));
  	   highlightCurrentByNick(nextNick);
  	
  	   var pid = s.waitingPickId || s.nextPickId || null;
  	   $("#btnBegin").data('pickid', pid).prop('disabled', !pid);
  	   return;
  	}
    }

  $(document).on("click", "#btnBid", function(){
    if (!G.code) { alert("세션 없음"); return; }
    if (!G.currentPickId) { alert("입찰 진행중인 건이 없습니다."); return; }

    var current = parseInt($("#currentPrice").text()||"0",10);
    var amount  = parseInt($("#bidAmount").val()||"0",10);
    if (isNaN(amount) || amount < 10 || (amount % 10) !== 0) {
      alert("입찰 금액은 10 단위여야 합니다. (예: 10, 20, 30 …)");
      $("#bidAmount").focus();
      return;
    }
    if (amount <= current) {
      alert("현재 경매가보다 큰 금액을 입력하세요.");
      $("#bidAmount").focus();
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
        alert(msg);
      } else {
        $(".hint").text("입찰 요청 완료! 서버 반영 중…");
      }
    }).fail(function(xhr){
      alert("네트워크 오류로 입찰 실패" + (xhr && xhr.status ? " ("+xhr.status+")" : ""));
    }).always(function(){
      $btn.prop("disabled", false).text("입찰");
    });
  });

  $(document).on("click", "#btnAllin", function(){
    if (!G.code || !G.currentPickId) { alert("입찰 진행중인 건이 없습니다."); return; }
    var $btn = $(this).prop("disabled", true);
    $.ajax({
      url: URLS.auctionBase + encodeURIComponent(G.code) + "/picks/" + G.currentPickId + "/bid",
      type: "POST",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify({ allin: "Y" })
    }).done(function(res){
      if (!res || res.success!==true){
        alert((res && res.error && res.error.msg) ? res.error.msg : "올인 실패");
      }
    }).fail(function(){
      alert("네트워크 오류로 올인 실패");
    }).always(function(){
      $btn.prop("disabled", false);
    });
  });

  $(document).on("change", "#bidAmount", function(){
    var v = parseInt($(this).val()||"0",10);
    if (isNaN(v) || v < 10 || (v % 10)!==0) {
      this.setCustomValidity("입찰 금액은 10 단위여야 합니다. (1~9 불가)");
    } else {
      this.setCustomValidity("");
    }
  });

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
        nick: assign.targetNick || '-',
        price: assign.price != null ? assign.price : '-',
        tier: assign.tier || '-',
        pos: assign.mrole || assign.srole || assign.pos || '-'
    };
    
    $rows.eq(0).find('td.m'+slot+'.nick').text(member.nick);
    $rows.eq(1).find('td.m'+slot+'.point').text(member.price);
    $rows.eq(2).find('td.m'+slot+'.tier').text(member.tier);
    $rows.eq(3).find('td.m'+slot+'.pos').text(member.pos);

    return true;
  }

})(window.jQuery || window.$);
</script>