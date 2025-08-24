<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="container">
  <div class="ca-toolbar">
    <div class="ca-left" id="toolbarLeft">
      <button id="btnSync" class="btn btn-blue">연동</button>
      <span id="syncInfo" class="ca-sync-info"></span>
    </div>
    <div class="ca-right" id="toolbarRight"></div>
  </div>

  <div class="ca-body">
    <table class="auc-table" id="memberTable">
      <colgroup>
        <col style="width:10%">
        <col style="width:32%">
        <col style="width:12%">
        <col style="width:12%">
        <col style="width:12%">
        <col style="width:14%">
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
      <tbody id="memberTbody">
        <tr><td colspan="7" class="td-empty">연동 버튼으로 데이터를 불러오세요</td></tr>
      </tbody>
    </table>
  </div>
</div>

<div id="loading-overlay" class="loading-overlay" style="display:none;">
  <div class="spinner"></div>
  <div style="margin-top:10px;">처리중입니다.</div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

<link rel="stylesheet" href="<c:url value='/resources/css/createAuction.css'/>">

<script>
var currentRows = [];

$(document).ready(function(){
  bindInitialToolbar();
  
  $(document).on('click', '#btnSync', function(){
    $('#loading-overlay').show();
    $.ajax({
      method:'POST',
      url:'<c:url value="/syncAuctionMembers"/>',
      dataType:'json'
    }).done(function(res){
      currentRows = (res && res.members) ? res.members : [];
      renderRows(currentRows);
      buildPostSyncToolbar(res);
    }).fail(function(){
      alert('연동 실패');
    }).always(function(){
      $('#loading-overlay').hide();
    });
  });

  $(document).on('click', '#btnSave', function(){
    if(!currentRows || currentRows.length === 0) return;

    var aucName = $('#auctionName').val() || '';
    if(aucName.replace(/\s+/g,'').length === 0){
      alert('경매명을 입력하세요.');
      $('#auctionName').focus();
      return;
    }
    if(!confirm('현재 연동된 데이터를 저장하시겠습니까?')) return;

    $('#memberTbody tr').each(function(idx){
      var isLeader = (currentRows[idx] && currentRows[idx].LEADERFLG === 'Y');
      if (isLeader) {
        var $inp = $(this).find('input.only-digit');
        var val = ($inp.val() || '1000').trim();
        currentRows[idx].POINT = val;
      } else {
        currentRows[idx].POINT = '0';
      }
    });

    $('#loading-overlay').show();
    $.ajax({
      method:'POST',
      url:'<c:url value="/saveAuctionMembers"/>',
      contentType:'application/json; charset=UTF-8',
      data: JSON.stringify({members: currentRows, auctionName: aucName})
    }).done(function(res){
      if(res && res.ok){ alert('저장 완료'); location.reload();}
      else{ alert((res && res.message) ? res.message : '저장 실패'); }
    }).fail(function(){
      alert('서버 오류');
    }).always(function(){ 
      $('#loading-overlay').hide();
    });
  });

  $(document).on('click', '#btnReset', function(){
    resetToInitial();
  });

  $(document).on('input', 'input.only-digit', function(){
    const digits = (this.value || '').replace(/\D+/g, '');
    const maxLen = this.maxLength > 0 ? this.maxLength : Infinity;
    this.value = digits.slice(0, maxLen);
  });

  $(document).on('blur', 'input.only-digit', function(){
    if ((this.value || '').trim() === '') this.value = '1000';
  });
});

function bindInitialToolbar(){
  $('#toolbarLeft').html('');
  $('#toolbarRight').html(
	'<button id="btnSync" class="btn btn-blue">연동</button>' +
    '<span id="syncInfo" class="ca-sync-info"></span>'
	);
}

function buildPostSyncToolbar(res){
  var syncedAt = (res && res.syncedAt) ? res.syncedAt : '';
  var codeTxt  = (res && res.code) ? res.code : '';
  $('#toolbarLeft').html(
    '<span id="syncInfo" class="ca-sync-info">'
      + '연동 시각: ' + escapeHtml(syncedAt)
      + (codeTxt ? ' / Code: ' + escapeHtml(codeTxt) : '')
    + '</span>'
  );
  $('#toolbarRight').html(
    '<input type="text" id="auctionName" maxLength="25" class="ca-input" placeholder="경매명 작성">'
    + '<button id="btnSave" class="btn btn-blue">저장</button>'
    + '<button id="btnReset" class="btn btn-gray">초기화</button>'
  );
}

function resetToInitial(){
  currentRows = [];
  $('#memberTbody').html('<tr><td colspan="7" class="td-empty">연동 버튼으로 데이터를 불러오세요</td></tr>');
  bindInitialToolbar();
}

function escapeHtml(s){
  if (s == null) return '';
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\"/g, '&quot;')
    .replace(/\'/g, '&#39;');
}

function renderRows(rows){
  var $tb = $('#memberTbody');
  if(!rows || rows.length === 0){
    $tb.html('<tr><td colspan="7" class="td-empty">데이터가 없습니다</td></tr>');
    return;
  }
  var html = '';
  for(var i=0;i<rows.length;i++){
    var r = rows[i];
    var NO    = escapeHtml(r.NO);
    var NICK  = escapeHtml(r.NICK);
    var TIER  = escapeHtml(r.TIER);
    var MROLE = escapeHtml(r.MROLE);
    var SROLE = escapeHtml(r.SROLE);
    var isLeader = (r.LEADERFLG === 'Y');

    html += '<tr class="row_tr">'
          +   '<td class="td-center">' + NO + '</td>'
          +   '<td class="td-left" title="' + NICK + '">' + NICK + '</td>'
          +   '<td class="td-center">' + TIER + '</td>'
          +   '<td class="td-center">' + MROLE + '</td>'
          +   '<td class="td-center">' + SROLE + '</td>'
          +   '<td class="td-center">'
          +      (isLeader
                    ? '<input type="text" inputmode="numeric" pattern="\\d*" maxlength="4" '
                      + 'class="point-input only-digit" value="1000" data-index="'+i+'"/>'
                    : '')
          +   '</td>'
          +   '<td class="td-center">' + (isLeader ? '★' : '') + '</td>'
          + '</tr>';
  }
  $tb.html(html);
}
</script>
