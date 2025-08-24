<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="container">
  <div class="am-toolbar">
    <div class="am-toolbar-left">
      <input type="text" id="searchQuery" class="am-input" placeholder="제목 검색">
      <button id="btnSearch" class="am-btn am-btn-blue">검색</button>
    </div>
  </div>

  <div class="auction-manage-page">
    <aside class="am-left">
      <ul class="am-list" id="auctionList">
        <li class="am-empty">검색해 보세요.</li>
      </ul>
      <div class="am-pagination" id="auctionPaging"></div>
    </aside>

    <section class="am-right" id="detailPanel">
      <div class="am-placeholder">좌측에서 경매를 선택하세요.</div>
      <div class="am-detail hidden">
        <header class="am-detail-head">
          <h2 id="dTitle"></h2>
          <span id="dStatus" class="am-status"></span>
        </header>
        <div class="am-table-wrap">
          <table class="am-table">
            <thead>
              <tr>
                <th>순번</th><th>닉네임</th><th>티어</th>
                <th>주포지션</th><th>부포지션</th>
                <th>포인트</th><th>팀장여부</th>
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

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
<link rel="stylesheet" href="<c:url value='/resources/css/manageAuction.css'/>">

<script>
$(function(){
  var $list   = $('#auctionList');
  var $tbody  = $('#pTableBody');
  var $panel  = $('#detailPanel');
  var $detail = $panel.find('.am-detail');
  var $ph     = $panel.find('.am-placeholder');
  var $title  = $('#dTitle');
  var $status = $('#dStatus');

  var currentAucId = null;

  $('#btnSearch').on('click', function(){
    loadAuctionList(1);
  });

  function loadAuctionList(page){
    var q = $('#searchQuery').val() || '';
    $.getJSON('/getAucMainList', { query:q, page:page, size:10 }, function(res){
      renderAuctionList(res.list);
      renderPaging('#auctionPaging', res.page, loadAuctionList);
    });
  }

  function renderAuctionList(rows){
    if(!rows || rows.length===0){
      $list.html('<li class="am-empty">결과 없음</li>');
      return;
    }
    var html='';
    $.each(rows, function(i,a){
      html += '<li class="am-item" data-id="'+esc(a.id)+'">'
           +    '<div class="am-title">'+esc(a.title)+'</div>'
           +    '<div class="am-meta">'
           +      '<span>참여자 '+esc(a.participantCount)+'</span>'
           +      '<span class="am-status '+esc(a.status)+'">'+esc(a.status)+'</span>'
           +    '</div>'
           +  '</li>';
    });
    $list.html(html);
  }

  function loadMembers(aucId, page){
    $.getJSON('/getAuctionMembers/'+aucId, { page:page, size:10 }, function(res){
      renderMembers(res.list);
      renderPaging('#memberPaging', res.page, function(p){ loadMembers(aucId, p); });
    });
  }

  function renderMembers(rows){
    if(!rows || rows.length===0){
      $tbody.html('<tr><td colspan="7" class="td-empty">참여자가 없습니다</td></tr>');
      return;
    }
    var html='';
    $.each(rows, function(i,p){
      html+='<tr>'
          + '<td>'+safe(p.order)+'</td>'
          + '<td>'+safe(p.nickname)+'</td>'
          + '<td>'+safe(p.tier)+'</td>'
          + '<td>'+safe(p.mainPos)+'</td>'
          + '<td>'+safe(p.subPos)+'</td>'
          + '<td>'+safe(p.point)+'</td>'
          + '<td>'+(p.leader ? '팀장':'')+'</td>'
          + '</tr>';
    });
    $tbody.html(html);
  }

  $list.on('click', '.am-item', function(){
    var id = $(this).data('id');
    currentAucId = id;
    $list.find('.am-item.active').removeClass('active');
    $(this).addClass('active');

    $.getJSON('/getAucMainData/'+id, function(meta){
      $title.text(meta.title||'');
      $status.text(meta.status||'');
      $ph.addClass('hidden');
      $detail.removeClass('hidden');
      loadMembers(id,1);
    });
  });

  function renderPaging(selector, page, callback){
    var $p = $(selector);
    if(!page || page.totalPages<=1){ $p.html(''); return; }
    var html='';
    if(page.number>1) html+='<a href="#" data-p="'+(page.number-1)+'">이전</a>';
    html+=' <span>'+page.number+' / '+page.totalPages+'</span> ';
    if(page.number<page.totalPages) html+='<a href="#" data-p="'+(page.number+1)+'">다음</a>';
    $p.html(html);
    $p.find('a').click(function(e){
      e.preventDefault();
      callback($(this).data('p'));
    });
  }

  function esc(v){ return v==null?'':String(v).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  function safe(v){ return v==null?'':esc(v); }

  loadAuctionList(1);
});
</script>
