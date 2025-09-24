<!--- /pages/user/reorder.cfm (USER SIDE) --->
<cfif NOT structKeyExists(session, "userid")>
  <cflocation url="/laundryservice/index.cfm?fuse=login">
</cfif>

<!-- params -->
<cfparam name="url.fromOrderId" default="" />
<cfif NOT len(trim(url.fromOrderId))>
  <cflocation url="/laundryservice/index.cfm?fuse=orderhistory">
</cfif>

<cfobject component="components.OrderService" name="orderService">

<!-- Handle POST: user clicked "Confirm Reorder" -->
<cfif structKeyExists(form, "doReorder")>
  <cfset fromId = trim(form.fromOrderId)>
  <cfif NOT len(fromId)>
    <cflocation url="/laundryservice/index.cfm?fuse=orderhistory">
  </cfif>

  <cfset newOrderId = "" />
  <cfset createError = "" />

  <!-- Try common method names safely -->
  <cftry>
    <cfset newOrderId = orderService.reorder(session.userid, fromId)>
    <cfcatch type="any">
      <cftry>
        <cfset newOrderId = orderService.createOrderFromPrevious(session.userid, fromId)>
        <cfcatch type="any">
          <cftry>
            <cfset newOrderId = orderService.cloneOrder(session.userid, fromId)>
            <cfcatch type="any">
              <cftry>
                <cfset newOrderId = orderService.repeatOrder(session.userid, fromId)>
                <cfcatch type="any">
                  <cfset createError = cfcatch.message>
                </cfcatch>
              </cftry>
            </cfcatch>
          </cftry>
        </cfcatch>
      </cftry>
    </cfcatch>
  </cftry>

  <!-- On success, go to status (or details if you prefer) -->
  <cfif len(toString(newOrderId))>
    <cflocation url="/laundryservice/index.cfm?fuse=orderstatus">
  <cfelse>
    <cfset flashError = "We could not create the reorder. #encodeForHTML(createError)#">
  </cfif>
</cfif>

<!-- Fetch the source order + items for preview; try common method names -->
<cfset srcOrder = "" />
<cfset srcItems = "" />
<cftry>
  <cfset srcOrder = orderService.getOrderDetails(session.userid, url.fromOrderId) />
  <cfcatch type="any">
    <cftry><cfset srcOrder = orderService.getOrderById(session.userid, url.fromOrderId) /><cfcatch></cfcatch>
  </cftry>
</cfcatch>
</cftry>
<cfif NOT isQuery(srcOrder)>
  <cftry><cfset srcOrder = orderService.getOrderDetails(url.fromOrderId) /><cfcatch></cfcatch></cftry>
</cfif>
<cfif NOT isQuery(srcOrder)>
  <cftry><cfset srcOrder = orderService.getOrderById(url.fromOrderId) /><cfcatch></cfcatch></cftry>
</cfif>

<!-- Items (optional) -->
<cftry><cfset srcItems = orderService.getOrderItems(url.fromOrderId) /><cfcatch></cfcatch></cftry>

<cfset hasOrder = isQuery(srcOrder) AND srcOrder.recordCount GT 0>
<cfset hasItems = isQuery(srcItems) AND srcItems.recordCount GT 0>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Reorder</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <style>
    :root{ --bg:#f4f6fb; --card:#fff; --text:#1f2937; --muted:#6b7280; --line:#e5e7eb;
           --brand:#5b5ee1; --ok:#22c55e; --info:#3b82f6; --danger:#ef4444;
           --shadow:0 8px 24px rgba(16,24,40,.08); --radius:16px; }
    *{ box-sizing:border-box }
    body{ margin:0; background:var(--bg); color:var(--text);
          font-family:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Arial; padding-bottom:80px; }
    .container{ max-width:780px; margin:0 auto; padding:12px 16px 24px; }
    .header{ position:sticky; top:0; z-index:10;
             background:linear-gradient(to bottom, rgba(244,246,251,1), rgba(244,246,251,.7) 60%, rgba(244,246,251,0));
             backdrop-filter:saturate(160%) blur(4px);
             padding:14px 0 8px; margin-bottom:10px; display:flex; align-items:center; gap:10px; }
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

    table{ width:100%; border-collapse:collapse; }
    th, td{ padding:10px; border-bottom:1px solid var(--line); font-size:14px; text-align:left; }
    th{ color:var(--muted); font-weight:700; }

    .actions{ display:flex; gap:10px; flex-wrap:wrap; margin-top:12px; }
    .btn{ display:inline-flex; align-items:center; gap:8px; padding:10px 12px; border-radius:12px;
          text-decoration:none; border:1px solid transparent; font-weight:800; }
    .btn-primary{ background:var(--brand); color:#fff; }
    .btn-secondary{ background:#fff; color:var(--brand); border-color:var(--brand); }

    .alert{ background:#fff7ed; border:1px solid #fed7aa; color:#9a3412; padding:10px 12px; border-radius:12px; margin-bottom:10px; }
    .footer-nav{ position:fixed; left:0; right:0; bottom:0; height:64px; background:#fff; border-top:1px solid var(--line);
                 display:flex; align-items:center; justify-content:space-around; z-index:20; -webkit-tap-highlight-color:transparent; }
    .footer-nav a{ text-decoration:none; color:var(--text); font-size:12px; display:flex; flex-direction:column; align-items:center; gap:4px; }
  </style>
</head>
<body>

<div class="container">
  <div class="header">
    <a href="/laundryservice/index.cfm?fuse=orderhistory" aria-label="Back to history"><i class="fas fa-arrow-left"></i></a>
    <h2>Reorder</h2>
  </div>

  <!-- Flash error (if any) -->
  <cfif structKeyExists(variables, "flashError") AND len(flashError)>
    <div class="alert"><cfoutput>#flashError#</cfoutput></div>
  </cfif>

  <!-- Source order preview -->
  <cfif hasOrder>
    <cfoutput>
      <div class="card">
        <div class="row"><span class="label"><i class="fas fa-hashtag"></i> From Order</span> <span class="value">LL-#encodeForHTML(srcOrder.OrderID[1])#</span></div>
        <div class="row"><span class="label"><i class="fas fa-calendar-alt"></i> Order Date</span> <span class="value">#DateFormat(srcOrder.OrderDate[1],"dd-mmm-yyyy")#</span></div>
        <div class="row"><span class="label"><i class="fas fa-tshirt"></i> Drop Type</span> <span class="value">#encodeForHTML(srcOrder.DropType[1])#</span></div>
        <div class="row"><span class="label"><i class="fas fa-list-ol"></i> Items</span> <span class="value">#encodeForHTML(srcOrder.TotalItems[1])#</span></div>
        <div class="row"><span class="label"><i class="fas fa-indian-rupee-sign"></i> Total</span> <span class="value">Rs. #NumberFormat(srcOrder.TotalEstimatedCost[1],"9,999.00")#</span></div>
        <div class="actions">
          <form method="post" action="/laundryservice/index.cfm?fuse=reorder" style="margin:0;">
            <input type="hidden" name="fromOrderId" value="#encodeForHTMLAttribute(srcOrder.OrderID[1])#">
            <button type="submit" name="doReorder" class="btn btn-primary"><i class="fas fa-rotate-right"></i> Confirm Reorder</button>
          </form>
          <a class="btn btn-secondary" href="/laundryservice/index.cfm?fuse=orderdetails&orderId=#URLEncodedFormat(srcOrder.OrderID[1])#"><i class="fas fa-eye"></i> View Details</a>
        </div>
      </div>
    </cfoutput>
  <cfelse>
    <div class="card">
      <p>We could not find the source order <strong>LL-<cfoutput>#encodeForHTML(url.fromOrderId)#</cfoutput></strong>.</p>
      <div class="actions">
        <a class="btn btn-secondary" href="/laundryservice/index.cfm?fuse=orderhistory"><i class="fas fa-arrow-left"></i> Back to History</a>
        <a class="btn btn-primary" href="/laundryservice/index.cfm?fuse=bookorder"><i class="fas fa-basket-shopping"></i> Book New Order</a>
      </div>
    </div>
  </cfif>

  <!-- Items table if available -->
  <cfif hasItems>
    <div class="card">
      <h3 style="margin:0 0 10px;">Items</h3>
      <table>
        <thead><tr><th>Item</th><th>Qty</th><th>Rate</th><th>Amount</th></tr></thead>
        <tbody>
          <cfoutput query="srcItems">
            <tr>
              <td>#encodeForHTML(ItemName)#</td>
              <td>#encodeForHTML(Qty)#</td>
              <td>Rs. #NumberFormat(Rate,"9,999.00")#</td>
              <td>Rs. #NumberFormat(Amount,"9,999.00")#</td>
            </tr>
          </cfoutput>
        </tbody>
      </table>
    </div>
  </cfif>
</div>

<!-- Bottom navbar -->
<nav class="footer-nav" aria-label="Bottom navigation">
  <a href="/laundryservice/index.cfm?fuse=dashboard"><span>🏠</span><span>Home</span></a>
  <a href="/laundryservice/index.cfm?fuse=orderstatus"><span>🚚</span><span>Status</span></a>
  <a href="/laundryservice/index.cfm?fuse=orderhistory"><span>📜</span><span>History</span></a>
  <a href="/laundryservice/index.cfm?fuse=profile"><span>👤</span><span>Profile</span></a>
</nav>

</body>
</html>
