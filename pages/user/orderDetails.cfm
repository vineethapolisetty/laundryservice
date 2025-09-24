<!--- /pages/user/orderDetails.cfm (USER SIDE) --->

<cfif NOT structKeyExists(session, "userid")>
  <cflocation url="/laundryservice/index.cfm?fuse=login">
</cfif>

<cfparam name="url.orderId" default="" />
<cfif NOT len(trim(url.orderId))>
  <cflocation url="/laundryservice/index.cfm?fuse=orderhistory">
</cfif>

<cfobject component="components.OrderService" name="orderService">

<cfset order = "" />
<cfset orderItems = "" />

<!-- Load order -->
<cftry>
  <cfset order = orderService.getOrderDetails(session.userid, url.orderId) />
  <cfcatch><cfset order = "" /></cfcatch>
</cftry>

<!-- Fallback if no matching method -->
<cfif NOT isQuery(order)>
  <cftry><cfset order = orderService.getOrderById(session.userid, url.orderId) /><cfcatch></cfcatch></cftry>
</cfif>

<!-- Items -->
<cftry><cfset orderItems = orderService.getOrderItems(url.orderId) /><cfcatch></cfcatch></cftry>

<cfset hasOrder = isQuery(order) AND order.recordCount GT 0>
<cfset hasItems = isQuery(orderItems) AND orderItems.recordCount GT 0>

<!-- Security: only allow this user's orders -->
<cfif hasOrder AND order.UserID[1] NEQ session.userid>
  <cfset hasOrder = false>
  <cfset hasItems = false>
  <cfset notAuthorized = true>
<cfelse>
  <cfset notAuthorized = false>
</cfif>

<cfset itemSummary = "">
<cfif hasItems>
  <cfset parts = []>
  <cfloop query="orderItems">
    <cfif val(Qty) GT 0>
      <cfset arrayAppend(parts, "#Qty# #ItemName#")>
    </cfif>
  </cfloop>
  <cfset itemSummary = arrayToList(parts, ", ")>
</cfif>


<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Order Details</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <style>
    :root{ --bg:#f4f6fb; --card:#fff; --text:#1f2937; --muted:#6b7280; --line:#e5e7eb;
           --brand:#5b5ee1; --ok:#22c55e; --info:#3b82f6; --danger:#ef4444;
           --shadow:0 8px 24px rgba(16,24,40,.08); --radius:16px; }
    body{ margin:0; background:var(--bg); color:var(--text);
          font-family:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Arial; padding-bottom:80px; }
    .container{ max-width:780px; margin:0 auto; padding:12px 16px 24px; }
    .header{ position:sticky; top:0; z-index:10; background:#fff;
             padding:14px 0 8px; margin-bottom:10px; display:flex; align-items:center; gap:10px; border-bottom:1px solid var(--line); }
    .header a{ color:var(--text); text-decoration:none; font-size:18px; display:inline-flex; align-items:center; }
    .header h2{ margin:0 auto; font-size:22px; font-weight:800; text-align:center; }
    .card{ background:var(--card); border:1px solid var(--line); border-radius:var(--radius);
           box-shadow:var(--shadow); padding:16px; margin-bottom:14px; }
    .row{ display:flex; align-items:center; gap:8px; margin:6px 0; color:var(--text); }
    .row i{ width:18px; text-align:center; color:var(--muted); }
    .label{ width:160px; color:var(--muted); }
    .value{ flex:1; font-weight:600; }
    .badge{ display:inline-block; padding:6px 10px; border-radius:999px; color:#fff; font-size:12px; font-weight:800; }
    .completed{ background:var(--ok); } .processing{ background:var(--info); }
    .cancelled{ background:var(--danger); } .active{ background:#6c757d; }
    table{ width:100%; border-collapse:collapse; } th,td{ padding:10px; border-bottom:1px solid var(--line); font-size:14px; text-align:left; }
    th{ color:var(--muted); font-weight:700; }
    .footer-nav{ position:fixed; left:0; right:0; bottom:0; height:64px; background:#fff; border-top:1px solid var(--line);
                 display:flex; align-items:center; justify-content:space-around; z-index:20; -webkit-tap-highlight-color:transparent; }
    .footer-nav a{ text-decoration:none; color:var(--text); font-size:12px; display:flex; flex-direction:column; align-items:center; gap:4px; }
    .btn{ display:inline-flex; align-items:center; gap:8px; padding:10px 12px; border-radius:12px;
          text-decoration:none; border:1px solid transparent; font-weight:800; cursor:pointer; }
    .btn-primary{ background:var(--brand); color:#fff; } .btn-secondary{ background:#fff; color:var(--brand); border-color:var(--brand); }
    .btn-danger{ background:#fff5f5; color:var(--danger); border:1px solid #ffe3e3; }
    .empty{ text-align:center; color:var(--muted); background:var(--card); border:1px dashed var(--line);
            border-radius:var(--radius); padding:24px; box-shadow:var(--shadow); }
  </style>
</head>
<body>

<div class="container">
  <div class="header">
    <a href="/laundryservice/index.cfm?fuse=orderhistory" aria-label="Back to history"><i class="fas fa-arrow-left"></i></a>
    <h2>Order Details</h2>
  </div>

  <cfif notAuthorized>
    <div class="empty">
      <p><i class="fas fa-ban"></i></p>
      <p>You are not authorized to view this order.</p>
      <p><a class="btn btn-secondary" href="/laundryservice/index.cfm?fuse=orderhistory"><i class="fas fa-arrow-left"></i> Back to History</a></p>
    </div>
  <cfelseif hasOrder>
    <cfoutput>
      <div class="card">
        <div class="row"><span class="label"><i class="fas fa-hashtag"></i> Order ID</span> <span class="value">LL-#order.OrderID[1]#</span></div>
        <div class="row"><span class="label"><i class="fas fa-calendar-alt"></i> Order Date</span> <span class="value">#DateFormat(order.OrderDate[1],"dd-mmm-yyyy")#</span></div>
        <div class="row"><span class="label"><i class="fas fa-tshirt"></i> Drop Type</span> <span class="value">#order.DropType[1]#</span></div>
<div class="row">
  <span class="label"><i class="fas fa-list-ol"></i> Items</span>
  <span class="value">
    <cfif len(itemSummary)>
      <cfoutput>#itemSummary#</cfoutput>
    <cfelse>
      #order.TotalItems[1]# items
    </cfif>
  </span>
</div>
        <div class="row"><span class="label"><i class="fas fa-indian-rupee-sign"></i> Total</span> <span class="value">Rs. #NumberFormat(order.TotalEstimatedCost[1],"9,999.00")#</span></div>
        <div class="row"><span class="label"><i class="fas fa-truck"></i> Status</span>
          <span class="value">
            <cfset st = order.Status[1]>
            <cfset stClass = (st EQ "Completed" ? "completed" : (st EQ "Processing" ? "processing" : (st EQ "Cancelled" ? "cancelled" : "active")))>
            <span class="badge #stClass#">#st#</span>
          </span>
        </div>
        <div class="row"><span class="label"><i class="far fa-calendar-check"></i> ETA</span>
          <span class="value">
            <cfif isDate(order.EstimatedDeliveryDate[1])>#DateFormat(order.EstimatedDeliveryDate[1],"dd-mmm-yyyy")#<cfelse>N/A</cfif>
          </span>
        </div>

        <div class="actions" style="margin-top:12px; display:flex; gap:10px; flex-wrap:wrap;">
          <a class="btn btn-primary" href="/laundryservice/index.cfm?fuse=reorder&fromOrderId=#URLEncodedFormat(order.OrderID[1])#"><i class="fas fa-rotate-right"></i> Reorder</a>
          <a class="btn btn-secondary" href="/laundryservice/index.cfm?fuse=orderstatus"><i class="fas fa-truck-fast"></i> Track</a>
          <cfif st EQ "Pending">
            <a class="btn btn-danger" href="/laundryservice/index.cfm?fuse=cancelorder&orderId=#URLEncodedFormat(order.OrderID[1])#"><i class="fas fa-times"></i> Cancel</a>
          </cfif>
        </div>
      </div>
    </cfoutput>
  <cfelse>
    <div class="empty">
      <p><i class="far fa-circle-question"></i></p>
      <p>We couldn’t find order <strong>LL-<cfoutput>#url.orderId#</cfoutput></strong>.</p>
      <p><a class="btn btn-secondary" href="/laundryservice/index.cfm?fuse=orderhistory"><i class="fas fa-arrow-left"></i> Back to History</a></p>
    </div>
  </cfif>

  <cfif hasItems>
    <div class="card">
      <h3 style="margin:0 0 10px;">Items</h3>
      <table>
        <thead><tr><th>Item</th><th>Qty</th><th>Rate</th><th>Amount</th></tr></thead>
        <tbody>
          <cfoutput query="orderItems">
            <tr>
              <td>#ItemName#</td>
              <td>#Qty#</td>
              <td>Rs. #NumberFormat(Rate,"9,999.00")#</td>
              <td>Rs. #NumberFormat(Amount,"9,999.00")#</td>
            </tr>
          </cfoutput>
        </tbody>
      </table>
    </div>
  </cfif>
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
</body>
</html>
