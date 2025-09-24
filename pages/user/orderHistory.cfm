<cfif NOT structKeyExists(session, "userid")>
  <cflocation url="/laundryservice/index.cfm?fuse=login">
</cfif>

<cfobject component="components.OrderService" name="orderService">
<cfset history = orderService.getOrderHistory(session.userid)>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Order History</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">

  <style>
    :root{
      --bg:#f4f6fb;
      --card:#ffffff;
      --text:#1f2937;
      --muted:#6b7280;
      --line:#e5e7eb;
      --brand:#5b5ee1;
      --ok:#22c55e;
      --info:#3b82f6;
      --warn:#f59e0b;
      --danger:#ef4444;
      --shadow: 0 8px 24px rgba(16,24,40,.08);
      --radius:16px;
    }
    *{box-sizing:border-box}
    body{ margin:0; background:var(--bg); color:var(--text); font-family:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Arial; padding-bottom:80px; }

    .container{ max-width:780px; margin:0 auto; padding:12px 16px 24px; }
    .header{
      position:sticky; top:0; z-index:10; background:linear-gradient(to bottom, rgba(244,246,251,1), rgba(244,246,251,.7) 60%, rgba(244,246,251,0));
      backdrop-filter:saturate(160%) blur(4px);
      padding:14px 0 8px; margin-bottom:10px; display:flex; align-items:center; gap:10px;
    }
    .header a{ color:var(--text); text-decoration:none; font-size:18px; display:inline-flex; align-items:center; }
    .header h2{ margin:0 auto; font-size:22px; font-weight:800; text-align:center; }

    .controls{
      display:flex; gap:8px; flex-wrap:wrap; margin:6px 0 14px;
    }
    .controls .field{
      flex:1 1 220px; background:var(--card); border:1px solid var(--line); border-radius:12px; display:flex; align-items:center; gap:8px; padding:8px 10px; box-shadow:var(--shadow);
    }
    .controls input, .controls select{
      width:100%; border:none; outline:none; background:transparent; font-size:14px; color:var(--text);
    }

    .summary{
      display:flex; gap:12px; flex-wrap:wrap; margin:6px 0 10px;
    }
    .pill{
      background:var(--card); border:1px solid var(--line); border-radius:999px; padding:8px 12px; font-size:12px; color:var(--muted); box-shadow:var(--shadow);
    }

    .order-card{
      background:var(--card); border:1px solid var(--line); border-radius:var(--radius); padding:16px; margin-bottom:14px; box-shadow:var(--shadow);
    }
    .order-header{ display:flex; align-items:center; justify-content:space-between; gap:10px; }
    .order-header h4{ margin:0; font-size:16px; font-weight:800; }
    .status-badge{
      padding:6px 10px; border-radius:999px; font-size:11px; font-weight:800; color:#fff; text-transform:uppercase; letter-spacing:.4px;
    }
    .completed{ background:var(--ok); }
    .processing{ background:var(--info); }
    .cancelled{ background:var(--danger); }
    .active{ background:#6c757d; }

    .order-details{ margin-top:10px; color:var(--text); font-size:14px; display:grid; gap:6px; }
    .order-details i{ width:18px; text-align:center; color:var(--muted); margin-right:8px; }
    .row{ display:flex; align-items:center; }

    .order-price{ margin-top:10px; font-weight:800; color:var(--text); }
    .order-actions{ display:flex; gap:10px; margin-top:12px; }
    .btn{
      flex:1; padding:10px 12px; border-radius:12px; border:1px solid transparent; cursor:pointer; font-weight:800; font-size:13px;
      display:inline-flex; align-items:center; justify-content:center; gap:8px; text-decoration:none;
    }
    .btn-primary{ background:var(--brand); color:#fff; }
    .btn-secondary{ background:#ffffff; color:var(--brand); border-color:var(--brand); }

    .empty{
      text-align:center; color:var(--muted); background:var(--card); border:1px dashed var(--line); border-radius:var(--radius);
      padding:24px; box-shadow:var(--shadow); margin-top:10px;
    }

    .footer-nav{
      position:fixed; left:0; right:0; bottom:0; height:64px; background:#ffffff; border-top:1px solid var(--line);
      display:flex; align-items:center; justify-content:space-around; z-index:20;
    }
    .footer-nav a{ text-decoration:none; color:var(--text); font-size:12px; display:flex; flex-direction:column; align-items:center; gap:4px; }
    .footer-nav a.active{ color:var(--brand); }

    /* Legacy links—kept but subtle */
    .legacy-links{ margin:20px auto 8px; max-width:780px; padding:0 16px; }
    .legacy-links ul{ display:flex; flex-wrap:wrap; gap:8px; list-style:none; padding:0; margin:0; }
    .legacy-links a{ font-size:12px; color:var(--muted); text-decoration:none; padding:6px 10px; border:1px dashed var(--line); border-radius:999px; }
  </style>
</head>
<body>

<div class="container">
  <div class="header">
    <a href="/laundryservice/index.cfm?fuse=dashboard" aria-label="Back to dashboard"><i class="fas fa-arrow-left"></i></a>
    <h2>Order History</h2>
  </div>

  <!-- Controls: client-side only (no service changes) -->
  <div class="controls">
    <div class="field"><i class="fas fa-magnifying-glass"></i>
      <input id="searchInput" type="search" placeholder="Search by Order ID, type…" oninput="filterCards()" />
    </div>
    <div class="field">
      <select id="statusFilter" onchange="filterCards()">
        <option value="">All Statuses</option>
        <option value="Completed">Completed</option>
        <option value="Processing">Processing</option>
        <option value="Cancelled">Cancelled</option>
        <option value="Active">Active</option>
      </select>
    </div>
    <div class="field">
      <select id="sortSelect" onchange="sortCards()">
        <option value="dateDesc">Newest first</option>
        <option value="dateAsc">Oldest first</option>
        <option value="amountDesc">Amount: high → low</option>
        <option value="amountAsc">Amount: low → high</option>
      </select>
    </div>
  </div>

 <!-- Summary pills -->
<cfif history.recordCount GT 0>
  <!-- compute totals and date range -->
  <cfset totalSpent = 0>
  <cfset minDate = history.orderDate[1]>
  <cfset maxDate = history.orderDate[1]>
  <cfloop query="history">
    <cfset totalSpent += val(TotalEstimatedCost)>
    <cfif history.orderDate LT minDate><cfset minDate = history.orderDate></cfif>
    <cfif history.orderDate GT maxDate><cfset maxDate = history.orderDate></cfif>
  </cfloop>
</cfif>

<!-- aggregate once from the existing history query -->
<cfquery name="histAgg" dbtype="query">
  SELECT MIN(OrderDate) AS minDate,
         MAX(OrderDate) AS maxDate,
         SUM(TotalEstimatedCost) AS totalSpent
  FROM history
</cfquery>

<div class="summary">
  <cfoutput>
    <span class="pill"><i class="far fa-list-alt"></i> <strong>#history.recordCount#</strong> orders</span>
    <cfif history.recordcount GT 0>
      <span class="pill"><i class="fas fa-indian-rupee-sign"></i>
        Spent: <strong>Rs. #NumberFormat(histAgg.totalSpent, "9,999,999.00")#</strong>
      </span>
      <span class="pill"><i class="far fa-calendar-alt"></i>
        Range: <strong>#DateFormat(histAgg.minDate, "dd-mmm-yyyy")# → #DateFormat(histAgg.maxDate, "dd-mmm-yyyy")#</strong>
      </span>
    </cfif>
  </cfoutput>
</div>



  <cfif history.recordCount EQ 0>
    <div class="empty">
      <p><i class="far fa-folder-open"></i></p>
      <p>No past orders found.</p>
      <p><a class="btn btn-primary" href="/laundryservice/index.cfm?fuse=bookorder"><i class="fas fa-basket-shopping"></i> Book Laundry</a></p>
    </div>
  <cfelse>
    <!-- Render each history item -->
    <div id="cards">
      <cfoutput query="history">
        <cfset statusClass = "active">
        <cfif Status EQ "Completed">
          <cfset statusClass = "completed">
        <cfelseif Status EQ "Processing">
          <cfset statusClass = "processing">
        <cfelseif Status EQ "Cancelled">
          <cfset statusClass = "cancelled">
        </cfif>

        <cfset safeOrderId = encodeForHTMLAttribute(OrderID)>
        <cfset safeStatus = encodeForHTML(Status)>
        <cfset safeDropType = encodeForHTML(DropType)>

        <div class="order-card"
             data-orderid="LL-#safeOrderId#"
             data-status="#safeStatus#"
             data-date="#DateFormat(OrderDate, 'yyyy-mm-dd')#"
             data-amount="#NumberFormat(TotalEstimatedCost, '9999999.99')#"
             data-droptype="#safeDropType#">
          <div class="order-header">
            <h4>Order LL-#encodeForHTML(OrderID)#</h4>
            <span class="status-badge #statusClass#">#safeStatus#</span>
          </div>

          <div class="order-details">
            <div class="row"><i class="fas fa-calendar-alt"></i> #DateFormat(OrderDate, "dd-mmm-yyyy")#</div>
            <div class="row"><i class="fas fa-tshirt"></i> #safeDropType# — #encodeForHTML(TotalItems)# items</div>
          </div>

          <div class="order-price">
            Total Paid: Rs. #NumberFormat(TotalEstimatedCost, "9,999.00")#
          </div>

          <div class="order-actions">
            <!-- Realistic links; keep your routes the same or adjust as needed -->
            <a class="btn btn-primary" href="/laundryservice/index.cfm?fuse=orderdetails&orderId=#URLEncodedFormat(OrderID)#">
              <i class="fas fa-eye"></i> View Details
            </a>
            <a class="btn btn-secondary" href="/laundryservice/index.cfm?fuse=reorder&fromOrderId=#URLEncodedFormat(OrderID)#">
              <i class="fas fa-rotate-right"></i> Reorder
            </a>
          </div>
        </div>
      </cfoutput>
    </div>
  </cfif>
</div>

<!-- Bottom Navbar (kept) -->
<nav class="footer-nav" aria-label="Bottom navigation">
  <a href="/laundryservice/index.cfm?fuse=dashboard"><span>🏠</span><span>Home</span></a>
  <a href="/laundryservice/index.cfm?fuse=orderstatus"><span>🚚</span><span>Status</span></a>
  <a class="active" href="/laundryservice/index.cfm?fuse=orderhistory"><span>📜</span><span>History</span></a>
  <a href="/laundryservice/index.cfm?fuse=profile"><span>👤</span><span>Profile</span></a>
</nav>

<!-- Keep original quick links (not removed, just styled subtly below) -->
<div class="legacy-links" aria-label="Quick links">
  <ul>
    <li><a href="/laundryservice/index.cfm?fuse=bookorder">Book Laundry</a></li>
    <li><a href="/laundryservice/index.cfm?fuse=orderstatus">Track Order</a></li>
    <li><a href="/laundryservice/index.cfm?fuse=orderhistory">Order History</a></li>
    <li><a href="/laundryservice/index.cfm?fuse=profile">Profile</a></li>
    <li><a href="/laundryservice/index.cfm?fuse=logout">Logout</a></li>
  </ul>
</div>

<!-- Optional back-to-home button (kept) -->
<div style="text-align:center; margin: 8px 0 90px;">
  <button onclick="window.location.href='/laundryservice/index.cfm?fuse=index&fuse=index&fuse=index&fuse=dashboard'" class="btn btn-secondary" style="border-radius:12px; padding:10px 16px;">
    Back to Home
  </button>
</div>

<script>
  // Client-side filtering and sorting (no backend changes)
  function filterCards(){
    const q = (document.getElementById('searchInput').value || '').toLowerCase().trim();
    const status = (document.getElementById('statusFilter').value || '').toLowerCase();
    const cards = document.querySelectorAll('#cards .order-card');
    cards.forEach(card=>{
      const id = (card.dataset.orderid || '').toLowerCase();
      const drop = (card.dataset.droptype || '').toLowerCase();
      const st = (card.dataset.status || '').toLowerCase();
      const hit = (!q || id.includes(q) || drop.includes(q)) && (!status || st === status);
      card.style.display = hit ? '' : 'none';
    });
  }

  function sortCards(){
    const by = document.getElementById('sortSelect').value;
    const wrap = document.getElementById('cards');
    if(!wrap) return;
    const cards = Array.from(wrap.children);
    cards.sort((a,b)=>{
      const da = a.dataset.date, db = b.dataset.date;
      const aa = parseFloat(a.dataset.amount||0), ab = parseFloat(b.dataset.amount||0);
      if(by === 'dateAsc'){ return (da>db) ? 1 : (da<db ? -1 : 0); }
      if(by === 'dateDesc'){ return (da<db) ? 1 : (da>db ? -1 : 0); }
      if(by === 'amountAsc'){ return aa - ab; }
      if(by === 'amountDesc'){ return ab - aa; }
      return 0;
    });
    cards.forEach(c=>wrap.appendChild(c));
  }

  // Initialize default sort
  document.addEventListener('DOMContentLoaded', ()=>{ sortCards(); });
</script>

</body>
</html>
