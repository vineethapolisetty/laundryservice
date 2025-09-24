<!--- /pages/user/notifications.cfm --->
<cfprocessingdirective pageencoding="utf-8">
<cfcontent type="text/html; charset=UTF-8">

<cfif NOT structKeyExists(session, "userid")>
  <cflocation url="/laundryservice/index.cfm?fuse=login" addtoken="false">
</cfif>

<!-- AJAX endpoint: /pages/user/notifications.cfm?ajax=1 -->
<cfif structKeyExists(url, "ajax")>
  <cfset data = { items = [] }>
  <cftry>
    <!-- Adjust table/columns to your schema if different -->
    <cfquery name="q" datasource="laundryservice">
  SELECT NotificationID, Message, IsRead, SentAt, OrderID
  FROM Notifications
  WHERE UserID = <cfqueryparam value="#session.userID#" cfsqltype="cf_sql_integer">
  ORDER BY SentAt DESC
  LIMIT 50
</cfquery>


    <cfloop query="q">
  <cfset arrayAppend(
    data.items,
    {
      id        = q.NotificationID,
      orderID   = q.OrderID,
      message   = toString(q.Message),
      isRead    = (q.IsRead EQ 1 OR lcase(q.IsRead) EQ "true"),
      sentAt    = (isDate(q.SentAt) ? dateTimeFormat(q.SentAt, "dd-mmm-yyyy HH:nn") : "")
    }
  )>
</cfloop>


    <cfcatch> <!-- if table missing or any error, return empty list gracefully --> </cfcatch>
  </cftry>

  <cfoutput>#serializeJSON(data)#</cfoutput>
  <cfabort>
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Notifications</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    :root{ --bg:#f4f6f8; --card:#fff; --text:#1f2937; --muted:#6b7280; --line:#e5e7eb; --brand:#5b5ee1; --radius:16px; --shadow:0 8px 24px rgba(16,24,40,.08); }
    *{ box-sizing:border-box }
    body{ margin:0; background:var(--bg); color:var(--text); font-family:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Arial; padding-bottom:80px; }
    .header{ position:sticky; top:0; z-index:10; background:#fff; border-bottom:1px solid var(--line); padding:14px 16px; display:flex; align-items:center; gap:10px; }
    .header a{ color:var(--text); text-decoration:none; font-size:18px; }
    .header h2{ margin:0 auto; font-size:20px; font-weight:800; text-align:center; }
    .container{ max-width:780px; margin:0 auto; padding:16px; }
    .card{ background:var(--card); border:1px solid var(--line); border-radius:var(--radius); box-shadow:var(--shadow); padding:0; overflow:hidden; }
    .list{ list-style:none; margin:0; padding:0; }
    .item{ display:flex; gap:12px; align-items:flex-start; padding:14px 16px; border-bottom:1px solid var(--line); }
    .item:last-child{ border-bottom:none; }
    .dot{ width:10px; height:10px; border-radius:999px; margin-top:6px; background:#22c55e; }
    .dot.read{ background:#cbd5e1; }
    .meta{ font-size:12px; color:var(--muted); margin-top:4px; }
    .toolbar{ display:flex; justify-content:space-between; align-items:center; padding:12px 16px; border-bottom:1px solid var(--line); background:#fff; }
    .btn{ display:inline-flex; align-items:center; gap:8px; padding:8px 12px; border-radius:10px; border:1px solid var(--line); background:#fff; cursor:pointer; font-weight:700; font-size:13px; }
    .btn-primary{ background:var(--brand); color:#fff; border-color:transparent; }
    .empty{ padding:28px; text-align:center; color:var(--muted); }
    .footer-nav{ position:fixed; left:0; right:0; bottom:0; height:64px; background:#fff; border-top:1px solid var(--line); display:flex; align-items:center; justify-content:space-around; z-index:20; }
    .footer-nav a{ text-decoration:none; color:var(--text); font-size:12px; display:flex; flex-direction:column; align-items:center; gap:4px; }
    .footer-nav a.active{ color:var(--brand); }
  </style>
</head>
<body>

<div class="header">
  <a href="/laundryservice/index.cfm?fuse=profile" aria-label="Back"><i class="fa-solid fa-arrow-left"></i></a>
  <h2>Notifications</h2>
</div>

<div class="container">
  <div class="card">
    <div class="toolbar">
      <strong>Latest</strong>
      <div>
        <button class="btn" onclick="refreshList()"><i class="fa-solid fa-rotate"></i> Refresh</button>
      </div>
    </div>
    <ul id="notifList" class="list">
      <li class="empty">Loading…</li>
    </ul>
  </div>
</div>

<nav class="footer-nav" aria-label="Bottom navigation">
  <a href="/laundryservice/index.cfm?fuse=dashboard"><i class="fa-solid fa-house"></i><span>Home</span></a>
  <a href="/laundryservice/index.cfm?fuse=orderhistory"><i class="fa-solid fa-clipboard-list"></i><span>History</span></a>
  <a href="/laundryservice/index.cfm?fuse=profile" class="active"><i class="fa-solid fa-user"></i><span>Profile</span></a>
</nav>

<script>
  async function refreshList(){
    const ul = document.getElementById('notifList');
    try{
      const res = await fetch('notifications.cfm?ajax=1', { headers:{'Accept':'application/json'} });
      const data = await res.json();
      const items = (data && data.items) || [];
      ul.innerHTML = '';
      if(items.length === 0){
        ul.innerHTML = '<li class="empty">No notifications.</li>';
        return;
      }
      items.forEach(n=>{
        const li = document.createElement('li');
        li.className = 'item';
        li.innerHTML = `
  <span class="dot ${n.isRead ? 'read' : ''}"></span>
  <div>
    <div>${escapeHtml(n.message || '')}</div>
    <div class="meta">
      ${n.orderID ? 'Order #' + n.orderID + ' • ' : ''}
      ${escapeHtml(n.sentAt || '')}
    </div>
  </div>`;

        ul.appendChild(li);
      });
    }catch(e){
      ul.innerHTML = '<li class="empty">Couldn’t load notifications.</li>';
      console.error(e);
    }
  }

  function escapeHtml(s){
    return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
  }

  // initial load + refresh every 60s
  refreshList();
  setInterval(refreshList, 60000);
</script>
</body>
</html>
