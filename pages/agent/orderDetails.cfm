<cfparam name="url.orderid" default="">
<cfif NOT structKeyExists(session, "agentid") OR NOT isNumeric(url.orderid)>
  <cflocation url="/laundryservice/index.cfm?fuse=agent_dashboard">
</cfif>

<cfobject component="components.AgentService" name="agentService">
<cfset order = agentService.getOrderDetail(url.orderid, session.agentid)>
<cfif order.recordCount EQ 0>
  <cfoutput><h2>Unauthorized or invalid order.</h2></cfoutput>
  <cfabort>
</cfif>
<cfset items = agentService.getOrderItems(url.orderid)>
<cfset activities = agentService.getOrderActivities(url.orderid)>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Order Detail</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="https://unpkg.com/@phosphor-icons/web"></script>
</head>

<body class="bg-gray-100 font-sans min-h-screen pb-24">
  <div class="max-w-md mx-auto p-4">

    <!-- Back and Contact -->
    <div class="flex justify-between items-center mb-4">
      <a href="/laundryservice/index.cfm?fuse=agent_dashboard" class="text-sm text-indigo-600 inline-flex items-center">
        <i class="ph ph-arrow-left mr-2"></i> Back
      </a>
      <a href="tel:<cfoutput>#encodeForHTMLAttribute(order.CustomerPhone)#</cfoutput>" class="text-indigo-600 text-sm inline-flex items-center">
        <i class="ph ph-phone mr-1"></i> Call Customer
      </a>
    </div>

    <h1 class="text-xl font-semibold mb-4">Order Detail</h1>

    <!-- Order Summary -->
    <div class="bg-white p-4 rounded-2xl shadow-sm mb-4">
      <h2 class="text-base font-semibold mb-3 text-gray-700">Order Summary</h2>
      <div class="text-sm text-gray-600 space-y-1">
        <p><strong>Order ID:</strong> <cfoutput>#encodeForHTML(order.OrderID)#</cfoutput></p>
        <p><strong>Customer:</strong> <cfoutput>#encodeForHTML(order.CustomerName)#</cfoutput></p>
        <p><strong>Service:</strong> <cfoutput>#encodeForHTML(order.ServiceType)#</cfoutput></p>
        <p><strong>Pickup:</strong> <cfoutput>#encodeForHTML(order.PickupAddress)#</cfoutput></p>
        <p><strong>Drop-off:</strong> <cfoutput>#encodeForHTML(order.DropoffAddress)#</cfoutput></p>
      </div>
      <p class="mt-3 text-green-600 font-bold text-lg">$<cfoutput>#NumberFormat(Val(order.TotalAmount), '9,999.00')#</cfoutput></p>
      <p class="mt-2">
        <span class="inline-block px-2 py-1 text-xs rounded-full font-medium
        <cfif order.Status EQ 'Pending' OR order.Status EQ 'Pending Pickup'> bg-yellow-100 text-yellow-700
        <cfelseif order.Status EQ 'Delivered'> bg-green-100 text-green-700
        <cfelseif order.Status EQ 'In Progress' OR order.Status EQ 'InProgress'> bg-blue-100 text-blue-700
        <cfelse> bg-gray-200 text-gray-700</cfif>">
          <cfoutput>#encodeForHTML(order.Status)#</cfoutput>
        </span>
      </p>
    </div>

    <!-- Items with AJAX -->
    <form id="countForm">
      <div class="bg-white p-4 rounded-2xl shadow-sm mb-4">
        <h2 class="text-base font-semibold mb-3 text-gray-700">Item Counts</h2>
        <cfloop query="items">
          <div class="flex justify-between items-center mb-3">
            <div>
              <p class="font-medium text-sm text-gray-800"><cfoutput>#encodeForHTML(ItemName)#</cfoutput></p>
              <p class="text-xs text-gray-500">Est: <cfoutput>#encodeForHTML(EstimatedCount)#</cfoutput></p>
            </div>
            <input type="number" name="count[#encodeForHTMLAttribute(ItemID)#]"
                   value="<cfoutput>#encodeForHTMLAttribute(ActualCount)#</cfoutput>"
                   class="w-16 border rounded p-1 text-center text-sm" min="0">
          </div>
        </cfloop>
        <input type="hidden" name="orderid" value="<cfoutput>#encodeForHTMLAttribute(order.OrderID)#</cfoutput>">
        <button type="submit" class="w-full bg-indigo-600 text-white py-2 rounded-full text-sm font-semibold mt-2">Save Counts</button>
      </div>
    </form>

    <!-- Schedule -->
    <form id="scheduleForm">
      <div class="bg-white p-4 rounded-2xl shadow-sm mb-4">
        <h2 class="text-base font-semibold mb-3 text-gray-700">Schedule</h2>
        <p class="text-sm text-gray-600 mb-1">
          Pickup:
          <cfoutput>#LSDateFormat(order.PickupDate)# @ #TimeFormat(order.PickupTime, 'hh:mm tt')#</cfoutput>
        </p>
        <p class="text-sm text-gray-600 mb-3">
          Delivery:
          <cfoutput>#LSDateFormat(order.DeliveryDate)# @ #TimeFormat(order.DeliveryTime, 'hh:mm tt')#</cfoutput>
        </p>

        <label class="text-sm mb-1 block">New Delivery Date</label>
        <input type="date" name="newDate"
               value="<cfoutput>#encodeForHTMLAttribute(DateFormat(order.DeliveryDate, 'yyyy-mm-dd'))#</cfoutput>"
               class="w-full border rounded p-2 text-sm mb-2">

        <label class="text-sm mb-1 block">New Delivery Time</label>
        <input type="time" name="newTime"
               value="<cfoutput>#encodeForHTMLAttribute(TimeFormat(order.DeliveryTime, 'HH:mm'))#</cfoutput>"
               class="w-full border rounded p-2 text-sm">

        <input type="hidden" name="orderid" value="<cfoutput>#encodeForHTMLAttribute(order.OrderID)#</cfoutput>">
        <button type="submit" class="w-full bg-blue-600 text-white py-2 rounded-full mt-3 text-sm font-semibold">Update Schedule</button>
      </div>
    </form>

    <!-- Actions -->
    <div class="space-y-2 mt-6">
      <button class="w-full bg-green-600 text-white py-2 rounded-full text-sm font-semibold"
              onclick="updateStatus('Accepted')">Accept Order</button>
      <button class="w-full bg-red-600 text-white py-2 rounded-full text-sm font-semibold"
              onclick="updateStatus('Rejected')">Reject Order</button>
      <button class="w-full bg-gray-600 text-white py-2 rounded-full text-sm font-semibold"
              onclick="updateStatus('Delivered')">Mark as Delivered</button>
    </div>

    <!-- Activity Timeline -->
    <cfif structKeyExists(variables, "activities") AND activities.recordCount GT 0>
      <div class="bg-white p-4 rounded-2xl shadow-sm mt-6">
        <h2 class="text-base font-semibold mb-3 text-gray-700">Activity Timeline</h2>
        <ul class="text-sm text-gray-600 space-y-2">
          <cfloop query="activities">
            <li>
              <div class="flex items-start">
                <div class="h-2 w-2 mt-1 mr-2 bg-indigo-500 rounded-full"></div>
                <div>
                  <p><cfoutput>#encodeForHTML(Action)#</cfoutput></p>
                  <p class="text-xs text-gray-400">
                    <cfoutput>#LSDateFormat(ActivityDate)# @ #TimeFormat(ActivityDate, 'hh:mm tt')#</cfoutput>
                  </p>
                </div>
              </div>
            </li>
          </cfloop>
        </ul>
      </div>
    </cfif>

  </div>

  <!-- Bottom Tab Nav -->
  <div class="fixed bottom-0 left-0 right-0 bg-white shadow-md p-2 flex justify-around border-t z-50">
    <a href="/laundryservice/index.cfm?fuse=agent_dashboard" class="text-center text-indigo-600 text-sm">
      <i class="ph ph-house text-xl mb-1"></i><br>Dashboard
    </a>
    <a href="/laundryservice/index.cfm?fuse=agent_tracker" class="text-center text-gray-600 text-sm">
      <i class="ph ph-list text-xl mb-1"></i><br>Tracker
    </a>
    <a href="/laundryservice/index.cfm?fuse=agent_profile" class="text-center text-gray-600 text-sm">
      <i class="ph ph-user-circle text-xl mb-1"></i><br>Profile
    </a>
  </div>

  <!-- AJAX Logic -->
  <script>
    $('#countForm').on('submit', function(e) {
      e.preventDefault();
      $.post('../../ajax/updateCounts.cfm', $(this).serialize())
        .done(function() { alert('Counts updated!'); })
        .fail(function() { alert('Failed to update counts'); });
    });

    $('#scheduleForm').on('submit', function(e) {
      e.preventDefault();
      $.post('../../ajax/updateSchedule.cfm', $(this).serialize())
        .done(function() { alert('Schedule updated!'); })
        .fail(function() { alert('Failed to update schedule'); });
    });

    function updateStatus(status) {
      $.post('../../ajax/updateStatus.cfm', {
        orderid: '<cfoutput>#encodeForJavaScript(order.OrderID)#</cfoutput>',
        status: status
      })
      .done(function() {
        alert('Order marked as ' + status);
        location.reload();
      })
      .fail(function() {
        alert('Failed to update status');
      });
    }
  </script>

</body>
</html>
