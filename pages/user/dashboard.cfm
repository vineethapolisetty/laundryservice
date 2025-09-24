<!--- Session check --->
<cfif NOT structKeyExists(session, "userID")>
  <cflocation url="/laundryservice/index.cfm?fuse=login" addtoken="false">
</cfif>

<!--- AJAX endpoint for real-time data: /pages/user/dashboard.cfm?ajax=1 --->
<cfif structKeyExists(url, "ajax")>
  <cfset data = {
    metrics = { active=0, delivered=0, today=0, total=0 },
    recent  = []
  }>

  <cftry>
    <!-- Pull the user's orders (adjust table/column names as needed) -->
    <cfquery name="qOrders" datasource="laundryservice">
      SELECT
        OrderID,
        Status,
        CreatedAt,
        EstimatedDeliveryDate
      FROM Orders
      WHERE UserID = <cfqueryparam value="#session.userID#" cfsqltype="cf_sql_integer">
      ORDER BY CreatedAt DESC
      LIMIT 20
    </cfquery>

    <!-- Compute metrics -->
    <cfset data.metrics.total = qOrders.recordCount>
    <cfset deliveredCount = 0>
    <cfset todayCount = 0>

    <cfloop query="qOrders">
      <cfif Status EQ "Delivered"><cfset deliveredCount++></cfif>
      <cfif isDate(EstimatedDeliveryDate)
            AND DateFormat(EstimatedDeliveryDate, "yyyy-mm-dd") EQ DateFormat(Now(), "yyyy-mm-dd")>
        <cfset todayCount++>
      </cfif>
    </cfloop>

    <cfset data.metrics.delivered = deliveredCount>
    <cfset data.metrics.today     = todayCount>
    <cfset data.metrics.active    = max(0, data.metrics.total - deliveredCount)>

    <!-- Recent activity (top 5 newest) -->
    <cfset i = 1>
    <cfloop query="qOrders">
      <cfset arrayAppend(data.recent, {
        OrderID   = qOrders.OrderID,
        Status    = qOrders.Status,
        CreatedAt = LSDateFormat(qOrders.CreatedAt, "dd-mmm-yyyy")
      })>
      <cfset i++>
      <cfif i GT 5><cfbreak></cfif>
    </cfloop>

    <cfcatch type="any">
      <!-- Silently fall back to zeros; still respond -->
    </cfcatch>
  </cftry>

  <cfoutput>#serializeJSON(data)#</cfoutput>
  <cfabort>
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>User Dashboard</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    :root{
      --primary:#5b5ee1;
      --bg:#f7f7fb;
      --card:#ffffff;
      --text:#1f2937;
      --muted:#6b7280;
      --border:#e5e7eb;
      --shadow:0 8px 24px rgba(0,0,0,.06);
    }
    *{box-sizing:border-box}
    body{
      margin:0; font-family:Inter, system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
      background:linear-gradient(180deg,#fafaff 0%, #f4f6fb 100%);
      color:var(--text); display:flex; min-height:100vh;
    }

    /* Sidebar */
    .sidebar{
      width:260px; background:var(--card); border-right:1px solid var(--border);
      position:fixed; inset:0 auto 0 0; padding:24px; box-shadow:var(--shadow);
      transition:transform .3s ease;
    }
    .sidebar.hidden{ transform:translateX(-100%); }
    .brand{
      display:flex; align-items:center; gap:10px; margin-bottom:24px;
    }
    .brand .logo{
      height:40px; width:40px; border-radius:12px; display:grid; place-items:center;
      background:radial-gradient(120px 60px at 20% 20%, #7c7fee, #5356e1);
      color:#fff; font-weight:800;
      box-shadow:0 6px 16px rgba(91,94,225,.35);
    }
    .nav a{
      display:flex; align-items:center; gap:10px; text-decoration:none; color:var(--text);
      padding:10px 12px; border-radius:10px; transition:all .15s ease; margin:4px 0;
    }
    .nav a:hover{ background:#f2f4ff; color:var(--primary); transform:translateX(2px); }
    .logout{
      display:inline-flex; align-items:center; gap:8px; background:#ef4444; color:#fff !important;
      padding:9px 12px; border-radius:10px; text-decoration:none; margin-top:10px; box-shadow:0 6px 16px rgba(239,68,68,.25);
    }

    /* Main */
    .main{ margin-left:260px; width:calc(100% - 260px); padding:28px; transition:margin-left .3s ease; }
    .main.full{ margin-left:0; width:100%; }
    .topbar{
      background:var(--card); border:1px solid var(--border); border-radius:16px; padding:12px 16px;
      display:flex; align-items:center; justify-content:space-between; box-shadow:var(--shadow);
    }
    .left{ display:flex; align-items:center; gap:12px; }
    .toggle-btn{
      height:40px; width:40px; display:grid; place-items:center; border:none; background:#eef1ff;
      border-radius:12px; color:var(--primary); font-size:20px; cursor:pointer; transition:transform .1s;
    }
    .toggle-btn:active{ transform:scale(.97); }

    /* Cards / KPIs */
    .grid{ display:grid; gap:16px; }
    .grid-4{ grid-template-columns:repeat(4,minmax(0,1fr)); }
    .card{
      background:var(--card); border:1px solid var(--border); border-radius:16px; padding:18px;
      box-shadow:var(--shadow);
    }
    .kpi{
      display:flex; align-items:center; gap:12px; color:#fff; border-radius:16px; padding:18px; box-shadow:var(--shadow);
    }
    .kpi .icon{
      height:44px; width:44px; border-radius:12px; display:grid; place-items:center;
      background:rgba(255,255,255,.22); font-size:20px;
    }
    .kpi .meta{ line-height:1.1; }
    .kpi .label{ font-size:12px; opacity:.95; }
    .kpi .value{ font-size:28px; font-weight:800; letter-spacing:.3px; }

    .kpi-1{ background:linear-gradient(135deg,#6c70f0,#5b5ee1); }
    .kpi-2{ background:linear-gradient(135deg,#22c55e,#16a34a); }
    .kpi-3{ background:linear-gradient(135deg,#f59e0b,#f97316); }
    .kpi-4{ background:linear-gradient(135deg,#64748b,#475569); }

    /* Loader */
    .loader{ display:flex; align-items:center; gap:8px; color:var(--muted); }
    .spinner{
      width:14px; height:14px; border:2px solid #cbd5e1; border-top-color:var(--primary); border-radius:50%;
      display:inline-block; animation:spin .8s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }

    /* Responsive */
    @media (max-width: 900px){
      .sidebar{ transform:translateX(-100%); }
      .sidebar.show{ transform:translateX(0); }
      .main{ margin-left:0; width:100%; padding:18px; }
      .grid-4{ grid-template-columns:repeat(2,minmax(0,1fr)); }
    }
    @media (max-width: 520px){
      .grid-4{ grid-template-columns:1fr; }
    }
  </style>
</head>
<body>

<!-- Sidebar -->
<aside class="sidebar" id="sidebar">
  <div class="brand">
    <div class="logo">LL</div>
    <div>
      <div style="font-weight:800;">LaundryLink</div>
      <div style="font-size:12px; color:var(--muted);">User Portal</div>
    </div>
  </div>

  <nav class="nav">
    <a href="/laundryservice/index.cfm?fuse=dashboard">🏠 Dashboard</a>
    <a href="/laundryservice/index.cfm?fuse=bookorder">🧺 Book Order</a>
    <a href="/laundryservice/index.cfm?fuse=orderstatus">🔍 Track Status</a>
    <a href="/laundryservice/index.cfm?fuse=orderhistory">🕒 Order History</a>
    <a href="/laundryservice/index.cfm?fuse=profile">👤 Profile</a>
  </nav>

  <a href="/laundryservice/index.cfm?fuse=logout" class="logout">🚪 Logout</a>
</aside>

<!-- Main Content -->
<main class="main" id="main">
  <div class="topbar">
    <div class="left">
      <button class="toggle-btn" onclick="toggleSidebar()">☰</button>
      <div>
        <div style="font-weight:700;">Welcome, <cfoutput>#encodeForHTML(session.userName)#</cfoutput> 👋</div>
        <div style="font-size:12px; color:var(--muted);">Here’s what’s happening with your orders</div>
      </div>
    </div>
    <a href="/laundryservice/index.cfm?fuse=logout" class="logout" style="box-shadow:none;">Logout</a>
  </div>

  <!-- KPIs -->
  <section class="grid grid-4" style="margin-top:18px;">
    <div class="kpi kpi-1">
      <div class="icon">📦</div>
      <div class="meta">
        <div class="label">Active Orders</div>
        <div id="kpiActive" class="value">0</div>
      </div>
    </div>
    <div class="kpi kpi-2">
      <div class="icon">✅</div>
      <div class="meta">
        <div class="label">Delivered</div>
        <div id="kpiDelivered" class="value">0</div>
      </div>
    </div>
    <div class="kpi kpi-3">
      <div class="icon">📅</div>
      <div class="meta">
        <div class="label">Due Today</div>
        <div id="kpiToday" class="value">0</div>
      </div>
    </div>
    <div class="kpi kpi-4">
      <div class="icon">Σ</div>
      <div class="meta">
        <div class="label">Total Orders</div>
        <div id="kpiTotal" class="value">0</div>
      </div>
    </div>
  </section>

  <!-- Quick action -->
  <section class="card" style="margin-top:16px;">
    <h3 style="margin:0 0 8px;">🧺 Quick Order</h3>
    <p style="margin:0;">
      Need a pickup? <a href="/laundryservice/index.cfm?fuse=bookorder" style="color:var(--primary); font-weight:600; text-decoration:none;">Book a new order</a>.
    </p>
  </section>

  <!-- Recent Activity -->
  <section class="card">
    <h3 style="margin:0 0 10px;">📈 Recent Activity</h3>
    <div id="recentLoader" class="loader"><span class="spinner"></span><span>Loading…</span></div>
    <ul id="recentList" style="margin:10px 0 0; padding-left:18px;"></ul>
  </section>
</main>

<!-- JavaScript -->
<script>
  function toggleSidebar(){
    const sb = document.getElementById('sidebar');
    const main = document.getElementById('main');
    sb.classList.toggle('show');
    sb.classList.toggle('hidden');
    main.classList.toggle('full');
  }

  async function loadDashboard(){
    const loader = document.getElementById("recentLoader");
    const list   = document.getElementById("recentList");

    try{
      const res  = await fetch("dashboard.cfm?ajax=1&cb=" + Date.now(), { headers:{ "Accept":"application/json" } });
      const data = await res.json();

      // Hide loader when we get a response
      if(loader) loader.style.display = "none";

      // KPIs
      document.getElementById("kpiActive").textContent    = (data.metrics && data.metrics.active)    || 0;
      document.getElementById("kpiDelivered").textContent = (data.metrics && data.metrics.delivered) || 0;
      document.getElementById("kpiToday").textContent     = (data.metrics && data.metrics.today)     || 0;
      document.getElementById("kpiTotal").textContent     = (data.metrics && data.metrics.total)     || 0;

      // Recent
      list.innerHTML = "";
      const items = (data.recent || []);
      if(!items.length){
        list.innerHTML = '<li style="color:#6b7280;">No recent activity.</li>';
      }else{
        items.forEach(r=>{
          const li = document.createElement("li");
          li.textContent = `Order #${r.OrderID} — ${r.Status} — ${r.CreatedAt}`;
          list.appendChild(li);
        });
      }
    }catch(e){
      if(loader) loader.style.display = "none";
      list.innerHTML = '<li style="color:#ef4444;">Failed to load data. Retrying…</li>';
      console.error(e);
    }
  }

  // Initial + 30s refresh
  loadDashboard();
  setInterval(loadDashboard, 30000);
</script>

</body>
</html>
