<!--- orderStatus.cfm --->

<cfif NOT structKeyExists(session, "userid")>
  <cflocation url="/laundryservice/index.cfm?fuse=login">
</cfif>

<cfobject component="components.OrderService" name="orderService">
<cfset orders = orderService.getCurrentOrders(session.userid)>

<!--- Helper: compute progress % from a status string --->
<cfscript>
/**
 * Returns a numeric percentage for the progress bar based on the order status.
 * Uses forgiving contains-based checks to handle minor variations.
 */
function getProgress(required string status){
  var s = lcase(trim(arguments.status));
  if (findNoCase("delivered", s))          return 100;
  if (findNoCase("out for delivery", s))   return 85;
  if (findNoCase("processing", s))         return 60;
  if (findNoCase("picked", s))             return 40;
  if (findNoCase("placed", s))             return 20;
  return 10; // fallback
}

/**
 * Utility to mark a delivery stage as active based on current progress.
 * stageTarget is the % threshold at which that stage is considered active.
 */
function isStageActive(numeric progress, numeric stageTarget){
  return progress GTE stageTarget;
}
</cfscript>

<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Order Tracking</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">

  <style>
    :root{
      --bg:#f5f6fb;
      --card:#ffffff;
      --muted:#6b7280;
      --text:#1f2937;
      --primary:#4f46e5;   /* Indigo */
      --primary-contrast:#ffffff;
      --accent:#10b981;    /* Emerald */
      --border:#e5e7eb;
      --shadow:0 10px 20px rgba(0,0,0,.06), 0 6px 6px rgba(0,0,0,.04);
      --radius:14px;
    }

    *{box-sizing:border-box}
    body{
      font-family: system-ui, -apple-system, "Segoe UI", Roboto, Arial, "Noto Sans", "Apple Color Emoji", "Segoe UI Emoji";
      background: linear-gradient(180deg, #f7f7ff 0%, #f0f3ff 100%);
      color: var(--text);
      margin:0;
      padding:0;
    }

    .page{
      min-height:100svh;
      padding: 16px 16px 88px; /* bottom pad for fixed footer */
      display:flex;
      justify-content:center;
    }

    .container{
      width:100%;
      max-width: 560px;
    }

    /* Header */
    .header{
      position:sticky;
      top:0;
      z-index:5;
      background: transparent;
      padding: 8px 0 12px;
    }
    .header-inner{
      position:relative;
      display:flex;
      align-items:center;
      justify-content:center;
    }
    .back-button{
      position:absolute;
      left:0;
      display:inline-flex;
      align-items:center;
      gap:8px;
      font-size:14px;
      color:var(--text);
      background: rgba(255,255,255,.8);
      backdrop-filter: blur(4px);
      border:1px solid var(--border);
      padding:8px 10px;
      border-radius:10px;
      cursor:pointer;
      box-shadow: var(--shadow);
      transition: transform .06s ease;
    }
    .back-button:active{ transform: translateY(1px); }
    .header h2{
      margin:0;
      font-size: 22px;
      letter-spacing:.2px;
    }

    /* Hero card */
    .hero{
      background: var(--card);
      border:1px solid var(--border);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      overflow:hidden;
    }
    .hero img{
      width:100%;
      height:160px;
      object-fit:cover;
      display:block;
    }

    /* Order card */
    .order-card{
      background: var(--card);
      border:1px solid var(--border);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      padding:16px;
      margin-top:16px;
    }
    .order-header{
      display:flex;
      justify-content:space-between;
      align-items:center;
      gap:8px;
      margin-bottom:6px;
      font-weight:600;
      letter-spacing:.2px;
    }
    .badge{
      display:inline-flex;
      align-items:center;
      gap:6px;
      font-size:12px;
      font-weight:600;
      padding:6px 10px;
      border-radius:999px;
      background:#eef2ff;
      color:#3730a3;
      border:1px solid #e0e7ff;
      white-space:nowrap;
    }
    .order-meta{
      font-size:13px;
      color: var(--muted);
      display:flex;
      align-items:center;
      gap:10px;
      flex-wrap:wrap;
    }
    .order-meta .dot{
      width:4px; height:4px; border-radius:50%; background:#c7cad3; display:inline-block;
    }

    /* Progress */
    .progress{
      background:#eef2ff;
      border:1px solid #e0e7ff;
      height:10px;
      border-radius:999px;
      overflow:hidden;
      margin:12px 0 10px;
    }
    .progress-inner{
      height:100%;
      width:0%;
      background: linear-gradient(90deg, var(--primary) 0%, #7c3aed 100%);
      transition: width .35s ease;
    }
    .stages{
      list-style:none;
      padding:0;
      margin:10px 0 0;
      display:grid;
      grid-template-columns:1fr;
      gap:10px;
    }
    @media (min-width:480px){
      .stages{ grid-template-columns:repeat(2, 1fr); }
    }
    .stage{
      display:flex;
      align-items:center;
      gap:10px;
      font-size:14px;
      padding:10px 12px;
      border:1px dashed #e5e7eb;
      border-radius:12px;
      background: #fafafe;
    }
    .stage i{ opacity:.55; }
    .stage.active{
      border-style:solid;
      border-color:#d1fae5;
      background:#ecfdf5;
    }
    .stage.active i{
      color: var(--accent);
      opacity:1;
    }

    /* Buttons */
    .buttons{
      display:flex;
      gap:10px;
      margin-top:14px;
    }
    .btn{
      flex:1;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      gap:8px;
      padding:12px;
      border-radius:12px;
      font-weight:700;
      border:1px solid transparent;
      cursor:pointer;
      text-decoration:none;
      transition: transform .06s ease, box-shadow .2s ease, background .2s ease;
      box-shadow: var(--shadow);
      user-select:none;
    }
    .btn:active{ transform: translateY(1px); }
    .btn-primary{
      background: var(--primary);
      color: var(--primary-contrast);
    }
    .btn-outline{
      background:#ffffff;
      color: var(--primary);
      border-color:#c7d2fe;
    }

    /* Assistance card */
    .assist h3{
      margin:0 0 8px 0;
      font-size:18px;
    }

    /* Footer nav */
    .footer-nav{
      position: fixed;
      bottom: 0; left:0; right:0;
      height:64px;
      background:#ffffff;
      border-top:1px solid var(--border);
      display:flex;
      justify-content:space-around;
      align-items:center;
      box-shadow: 0 -6px 14px rgba(0,0,0,.04);
      z-index: 10;
    }
    .footer-nav a{
      text-decoration:none;
      color: var(--text);
      font-size:12px;
      text-align:center;
      line-height:1.1;
      display:flex;
      flex-direction:column;
      align-items:center;
      gap:4px;
      padding-top:6px;
    }
    .footer-nav a[aria-current="page"]{
      color: var(--primary);
      font-weight:700;
    }

    /* Empty state */
    .empty{
      background: var(--card);
      border:1px dashed var(--border);
      border-radius: var(--radius);
      padding:20px;
      margin-top:16px;
      text-align:center;
      color: var(--muted);
    }

    /* Hide legacy list but keep for fallback/SEO if you want */
    .legacy-links{ display:none; }
  </style>
</head>
<body>
  <div class="page">
    <div class="container">

      <!-- Header -->
      <div class="header">
        <div class="header-inner">
          <button class="back-button" type="button" onclick="history.back()" aria-label="Go back">
            <i class="fas fa-arrow-left"></i>
          </button>
          <h2>Order Tracking</h2>
        </div>
      </div>

      <!-- Hero -->
      <div class="hero" aria-hidden="true">
        <img src="/laundryservice/images/laundry.jpg" alt="">
      </div>

      <!-- Orders -->
      <cfif orders.recordCount EQ 0>
        <div class="empty">
          <p><i class="fas fa-info-circle"></i> You don’t have any active orders right now.</p>
          <p><a class="btn btn-primary" href="/laundryservice/index.cfm?fuse=bookorder"><i class="fas fa-plus-circle"></i> Book Laundry</a></p>
        </div>
      <cfelse>
        <cfoutput query="orders">
          <cfset currentProgress = getProgress(Status)>
          <div class="order-card">
            <div class="order-header">
              <div>Order ID: LAU-#OrderID#</div>
              <span class="badge"><i class="fas fa-circle-notch"></i> #Status#</span>
            </div>

            <div class="order-meta">
              <span><i class="far fa-calendar"></i> Estimated Delivery: #DateFormat(EstimatedDeliveryDate, "mmm d, yyyy")#</span>
              <span class="dot" aria-hidden="true"></span>
              <span><i class="far fa-clock"></i> Progress: #currentProgress#%</span>
            </div>

            <div class="progress" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="#currentProgress#">
              <div class="progress-inner" style="width:#currentProgress#%;"></div>
            </div>

            <ul class="stages" aria-label="Delivery stages">
              <!-- Stage thresholds: 20, 40, 60, 85, 100 -->
              <li class="stage #isStageActive(currentProgress,20)?'active':''#">
                <i class="fas fa-check-circle"></i> <span>Order Placed</span>
              </li>
              <li class="stage #isStageActive(currentProgress,40)?'active':''#">
                <i class="fas fa-check-circle"></i> <span>Laundry Picked Up</span>
              </li>
              <li class="stage #isStageActive(currentProgress,60)?'active':''#">
                <i class="fas fa-spinner"></i> <span>In Processing</span>
              </li>
              <li class="stage #isStageActive(currentProgress,85)?'active':''#">
                <i class="fas fa-truck"></i> <span>Out for Delivery</span>
              </li>
              <li class="stage #isStageActive(currentProgress,100)?'active':''#">
                <i class="fas fa-box-open"></i> <span>Delivered</span>
              </li>
            </ul>

            <div class="buttons">
              <!-- Use tel: and chat link targets you already have -->
              <a class="btn btn-primary" href="tel:+1800123456"><i class="fas fa-phone"></i> Call Support</a>
              <a class="btn btn-outline" href="/laundryservice/index.cfm?fuse=supportchat&orderId=#OrderID#"><i class="fas fa-comments"></i> Chat</a>
            </div>
          </div>
        </cfoutput>
      </cfif>

      <!-- Assistance -->
      <div class="order-card assist">
        <h3>Need Assistance?</h3>
        <div class="buttons">
          <a class="btn btn-primary" href="tel:+1800123456"><i class="fas fa-phone"></i> Call Support</a>
          <a class="btn btn-outline" href="/laundryservice/index.cfm?fuse=supportchat"><i class="fas fa-comments"></i> Chat with Us</a>
        </div>
      </div>

    </div>
  </div>

 <!-- Bottom Navbar -->
<nav class="footer-nav" role="navigation" aria-label="Primary">
  <a href="/laundryservice/index.cfm?fuse=dashboard">
    <i class="fas fa-home"></i>
    <span>Home</span>
  </a>
  <a href="/laundryservice/index.cfm?fuse=orderstatus" aria-current="page">
    <i class="fas fa-shipping-fast"></i>
    <span>Status</span>
  </a>
  <a href="/laundryservice/index.cfm?fuse=orderhistory">
    <i class="fas fa-receipt"></i>
    <span>History</span>
  </a>
  <a href="/laundryservice/index.cfm?fuse=profile">
    <i class="fas fa-user"></i>
    <span>Profile</span>
  </a>
</nav>


  <!-- (Optional) Keep your old plain links hidden for fallback -->
  <ul class="legacy-links">
    <li><a href="/laundryservice/index.cfm?fuse=bookorder">Book Laundry</a></li>
    <li><a href="/laundryservice/index.cfm?fuse=orderstatus">Track Order</a></li>
    <li><a href="/laundryservice/index.cfm?fuse=orderhistory">Order History</a></li>
    <li><a href="/laundryservice/index.cfm?fuse=profile">Profile</a></li>
    <li><a href="/laundryservice/index.cfm?fuse=logout">Logout</a></li>
  </ul>

  <!-- Tiny QoL: if user is at bottom nav, ensure content isn't obscured -->
  <script>
    // No JS required for core features; this is just a safe-guard for iOS visual quirks.
  </script>
</body>
</html>
