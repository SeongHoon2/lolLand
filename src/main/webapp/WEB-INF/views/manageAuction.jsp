<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="container">
  <div class="am-scope">

    <div class="auction-manage-page">
      <div class="am-left-col">
        <div class="am-searchbar">
          <input type="text" id="searchQuery" class="am-input" placeholder="제목 검색">
          <button type="button" id="btnSearch" class="am-btn am-btn-blue">검색</button>
        </div>

        <aside class="am-left">
          <ul class="am-list" id="auctionList">
            <li class="am-item am-empty-row"></li>
            <li class="am-item am-empty-row"></li>
            <li class="am-item am-empty-row"></li>
            <li class="am-item am-empty-row"></li>
            <li class="am-item am-empty-row"></li>
            <li class="am-item am-empty-row"></li>
            <li class="am-item am-empty-row"></li>
            <li class="am-item am-empty-row"></li>
          </ul>
          <div class="am-pagination" id="auctionPaging"></div>
        </aside>
      </div>

      <section class="am-right" id="detailPanel">
        <div class="am-placeholder">좌측에서 경매를 선택하세요.</div>

        <div class="am-detail hidden">
          <header class="am-detail-head">
            <h2 id="dTitle"></h2>
            <div class="am-statusline">
              <button type="button" id="dAction" class="am-meta-btn hidden"></button>
              <span id="dRand" class="am-rand-text"></span>
            </div>
          </header>

          <div class="am-table-wrap">
            <table class="am-table">
              <colgroup>
                <col style="width:7%">
                <col style="width:45%">
                <col style="width:10%">
                <col style="width:10%">
                <col style="width:10%">
                <col style="width:10%">
                <col style="width:8%">
              </colgroup>
              <thead>
                <tr>
                  <th>순번</th>
                  <th>닉네임</th>
                  <th>티어</th>
                  <th>주포지션</th>
                  <th>부포지션</th>
                  <th>포인트</th>
                  <th>팀장</th>
                </tr>
              </thead>
              <tbody id="pTableBody"></tbody>
            </table>
          </div>

          <div class="am-pagination" id="memberPaging"></div>
        </div>
      </section>
    </div>

  </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<link rel="stylesheet" href="<c:url value='/resources/css/manageAuction.css'/>">

<script>
$(function(){
  var AUC_PAGE_SIZE = 8;
  var MEM_PAGE_SIZE = 10;

  var $list   = $('#auctionList');
  var $tbody  = $('#pTableBody');
  var $panel  = $('#detailPanel');
  var $detail = $panel.find('.am-detail');
  var $ph     = $panel.find('.am-placeholder');
  var $title  = $('#dTitle');
  var $rand   = $('#dRand');
  var $action = $('#dAction');
  var $btnSearch = $('#btnSearch');
  var $q = $('#searchQuery');

  $btnSearch.on('click', function(){
    if ($btnSearch.prop('disabled')) return;
    loadAuctionList(1);
  });

  $q.on('keydown', function(e){
    if (e.key === 'Enter') {
      e.preventDefault();
      $btnSearch.click();
    }
  });

  loadAuctionList(1);

  function loadAuctionList(page){
    var q = $q.val() || '';
    $btnSearch.prop('disabled', true).addClass('is-loading');
    $.getJSON('/getAucMainList', { query:q, page:page, size:AUC_PAGE_SIZE })
      .done(function(res){
        renderAuctionList(res && res.list ? res.list : []);
        renderPaging('#auctionPaging', res && res.page ? res.page : {number:1,totalPages:1}, function(nextPage){
          loadAuctionList(nextPage);
        });
      })
      .fail(function(){
        alert('검색에 실패했습니다.');
      })
      .always(function(){
        $btnSearch.prop('disabled', false).removeClass('is-loading');
      });
  }

  function renderAuctionList(rows){
    var html='';
    for (var i=0;i<AUC_PAGE_SIZE;i++){
      if(rows[i]){
        var a = rows[i];
        var stCode = String(a.status || '').toUpperCase();
        var stTxt = stCode;
        if(stCode === 'SYNC'){ stTxt = '로비 오픈 대기중'; }
        else if(stCode === 'WAIT'){ stTxt = '경매 시작 대기중'; }
        else if(stCode === 'ING'){ stTxt = '경매 진행중'; }
        else if(stCode === 'END'){ stTxt = '경매 종료'; }
        html += '<li class="am-item" data-id="'+esc(a.id)+'">'
             +    '<div class="am-title">'+esc(a.title)+'</div>'
             +    '<div class="am-meta">'
             +      '<span class="am-status '+esc(stCode)+'">'+esc(stTxt)+'</span>'
             +    '</div>'
             +  '</li>';
      } else {
        html += '<li class="am-item am-empty-row"></li>';
      }
    }
    $list.html(html);
  }

  $list.on('click', '.am-item', function(){
    var id = $(this).data('id');
    if(!id) return;
    $list.find('.am-item.active').removeClass('active');
    $(this).addClass('active');

    $.getJSON('/getAucMainData/'+id, function(meta){
      $title.text(meta && meta.title ? meta.title : '');
      var statusCode = meta && meta.status ? String(meta.status).toUpperCase() : '';
      var rc = meta && (meta.randomCode || meta.RandomCode || meta.random_code || meta.code);
      rc = (rc == null ? '' : String(rc));
      $rand.text('Code : ' + esc(rc || ''));

      if (statusCode === 'SYNC'){
        $action.text('로비 오픈').removeClass('hidden').attr('data-action','open-lobby');
      } else if (statusCode === 'WAIT' || statusCode === 'ING'){
        $action.text('경매 강제 종료').removeClass('hidden').attr('data-action','force-end');
      } else {
        $action.addClass('hidden').removeAttr('data-action');
      }

      $ph.addClass('hidden');
      $detail.removeClass('hidden').addClass('shown');
      loadMembers(id, 1);
    });
  });

  function loadMembers(aucId, page){
    $.getJSON('/getAuctionMembers/'+aucId, { page:page, size:MEM_PAGE_SIZE }, function(res){
      renderMembers(res && res.list ? res.list : []);
      renderPaging('#memberPaging', res && res.page ? res.page : {number:1,totalPages:1}, function(nextPage){
        loadMembers(aucId, nextPage);
      });
    });
  }

  function renderMembers(rows){
    var html='';
    for (var i=0; i<MEM_PAGE_SIZE; i++){
      var p = rows[i];
      if (p){
        var isLeader = !!p.leader;
        var pointTxt = isLeader ? safe(p.point) : '';
        var leaderTxt = isLeader ? '★' : '';
        html+='<tr>'
            + '<td>'+safe(p.order)+'</td>'
            + '<td class="td-left">'+safe(p.nickname)+'</td>'
            + '<td>'+safe(p.tier)+'</td>'
            + '<td>'+safe(p.mainPos)+'</td>'
            + '<td>'+safe(p.subPos)+'</td>'
            + '<td>'+pointTxt+'</td>'
            + '<td>'+leaderTxt+'</td>'
            + '</tr>';
      } else {
        html+='<tr class="am-empty-row" aria-hidden="true">'
            +   '<td>&nbsp;</td>'
            +   '<td class="td-left">&nbsp;</td>'
            +   '<td>&nbsp;</td>'
            +   '<td>&nbsp;</td>'
            +   '<td>&nbsp;</td>'
            +   '<td>&nbsp;</td>'
            +   '<td>&nbsp;</td>'
            + '</tr>';
      }
    }
    $tbody.html(html);
  }

  function renderPaging(selector, page, callback){
    var $p = $(selector);
    var n = (page && page.number) ? page.number : 1;
    var t = (page && page.totalPages) ? page.totalPages : 1;

    var prevDis = (n <= 1) ? ' disabled' : '';
    var nextDis = (n >= t) ? ' disabled' : '';

    var html = ''
      + '<a href="#" class="am-page-btn am-prev'+prevDis+'" data-p="'+(Math.max(n-1,1))+'" aria-label="이전">‹</a>'
      + '<span class="am-page-info"><span class="am-page-num">'+n+'</span>/<span class="am-page-total">'+t+'</span></span>'
      + '<a href="#" class="am-page-btn am-next'+nextDis+'" data-p="'+(Math.min(n+1,t))+'" aria-label="다음">›</a>';

    $p.html(html);

    $p.find('a.am-page-btn').off('click').on('click', function(e){
      e.preventDefault();
      if($(this).hasClass('disabled')) return;
      var nextPage = parseInt($(this).attr('data-p'), 10);
      if(isNaN(nextPage) || nextPage < 1 || nextPage > t) return;
      callback(nextPage);
    });
  }

  function esc(v){ return v==null?'':String(v).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  function safe(v){ return v==null?'':esc(v); }
});
</script>
