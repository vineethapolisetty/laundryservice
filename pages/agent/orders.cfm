<!--- Secure Access --->
<cfif NOT structKeyExists(session, "agentid")>
    <cfheader statuscode="403">
    <cfabort>
</cfif>

<!-- Load assigned orders -->
<cfset agentService = new components.AgentService()>
<cfset orders = agentService.getAssignedOrders(session.agentid)>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Order Detail View</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- Tailwind CSS -->
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>

<body class="p-6 bg-gray-100 font-sans">
  <div class="max-w-4xl mx-auto">
    <h2 class="text-2xl font-bold mb-2">Order Detail View</h2>
    <a href="index.cfm?fuse=agent_dashboard" class="text-blue-600 hover:underline mb-6 inline-flex items-center">
      ← Back
    </a>

    <!-- 🔍 Search + Filter -->
<div class="flex flex-col md:flex-row md:items-center md:justify-between mb-6 gap-4">
  <input type="text" id="searchBox"
         placeholder="Search by Order ID or Customer..."
         class="flex-1 border p-2 rounded shadow-sm text-sm" />

  <div class="flex gap-2">
    <select id="statusFilter"
            class="border p-2 rounded shadow-sm text-sm">
      <option value="">All Statuses</option>
      <option value="Pending">Pending</option>
      <option value="In Progress">In Progress</option>
      <option value="Delivered">Delivered</option>
      <option value="Rejected">Rejected</option>
    </select>

    <!-- 🆕 Clear Button -->
    <button type="button" id="clearFilters"
            class="bg-gray-200 text-gray-700 px-3 py-2 rounded text-sm hover:bg-gray-300">
      Clear
    </button>
  </div>
</div>


    <!-- Orders Loop -->
    <cfoutput query="orders">
      <cfset items = agentService.getOrderItems(OrderID)>

      

      <!-- 🟢 Wrap each order in .orderCard -->
      <div class="orderCard bg-white p-6 rounded-lg shadow mb-8"
           data-orderid="#encodeForHTMLAttribute(OrderID)#"
           data-customer="#encodeForHTMLAttribute(CustomerName)#"
           data-status="#encodeForHTMLAttribute(Status)#">

        <!-- Order Summary -->
        <div class="flex items-center justify-between">
          <h3 class="text-xl font-semibold">Order #encodeForHTML(OrderID)#</h3>
          <span class="px-2 py-1 rounded text-sm bg-gray-200 text-gray-800">
            #encodeForHTML(Status)#
          </span>
        </div>

        <div class="grid md:grid-cols-2 gap-4 mt-4 text-sm">
          <p><strong>Customer Name:</strong> #encodeForHTML(CustomerName)#</p>
          <p><strong>Service Type:</strong> #encodeForHTML(ServiceType)#</p>
          <p><strong>Pickup Address:</strong> #encodeForHTML(PickupAddress)#</p>
          <p><strong>Dropoff Address:</strong> #encodeForHTML(DropoffAddress)#</p>
          <p><strong>Total Estimated Value:</strong>
            $#NumberFormat(Val(EstimatedValue), "9,999.00")#
          </p>
        </div>

        <!-- Item Details -->
        <h4 class="mt-6 font-semibold">Item Details &amp; Count</h4>
        <form method="post" action="../../ajax/updateCounts.cfm" class="mt-2">
          <input type="hidden" name="orderID" value="#encodeForHTMLAttribute(OrderID)#">
          <cfloop query="items">
            <div class="flex justify-between items-center my-2">
              <span class="text-sm">
                #encodeForHTML(ItemName)# (Est: #encodeForHTML(EstimatedCount)#)
              </span>
              <input type="number" name="actualCount_#encodeForHTMLAttribute(ItemID)#"
                     value="#encodeForHTMLAttribute(ActualCount)#"
                     min="0"
                     class="border px-2 py-1 w-24 rounded" />
            </div>
          </cfloop>
          <button type="submit" class="mt-3 bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
            Save Counts
          </button>
        </form>

        <!-- Pickup & Delivery -->
        <h4 class="mt-6 font-semibold">Pickup &amp; Delivery Schedule</h4>
        <form method="post" action="../../ajax/updateSchedule.cfm" class="mt-2 grid md:grid-cols-2 gap-3 items-end">
          <input type="hidden" name="orderID" value="#encodeForHTMLAttribute(OrderID)#">
          <p class="text-sm text-gray-700">
            <strong>Pickup:</strong>
            #dateFormat(PickupDate, "mmmm dd, yyyy")# @ #timeFormat(PickupTime, "hh:mm tt")#
          </p>
          <p class="text-sm text-gray-700">
            <strong>Delivery:</strong>
            #dateFormat(DeliveryDate, "mmmm dd, yyyy")# @ #timeFormat(DeliveryTime, "hh:mm tt")#
          </p>

          <div>
            <label class="block text-sm text-gray-600 mb-1">Update Delivery Date</label>
            <input type="date" name="newDate"
                   value="#encodeForHTMLAttribute(DateFormat(DeliveryDate, 'yyyy-mm-dd'))#"
                   class="border p-2 rounded w-full text-sm">
          </div>

          <div>
            <label class="block text-sm text-gray-600 mb-1">Update Delivery Time</label>
            <input type="time" name="newTime"
                   value="#encodeForHTMLAttribute(TimeFormat(DeliveryTime, 'HH:mm'))#"
                   class="border p-2 rounded w-full text-sm">
          </div>

          <div class="md:col-span-2">
            <button type="submit" class="bg-purple-600 text-white px-4 py-2 rounded hover:bg-purple-700">
              Update Schedule
            </button>
          </div>
        </form>

        <!-- Actions -->
        <h4 class="mt-6 font-semibold">Actions</h4>
        <form method="post" action="../../ajax/updateStatus.cfm" class="mt-2">
          <input type="hidden" name="orderID" value="#encodeForHTMLAttribute(OrderID)#">
          <div class="space-x-2">
            <button name="status" value="Accepted"  class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">Accept Order</button>
            <button name="status" value="Rejected"  class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700">Reject Order</button>
            <button name="status" value="Delivered" class="bg-gray-700 text-white px-4 py-2 rounded hover:bg-gray-800">Mark as Delivered</button>
          </div>
        </form>
      </div>
    </cfoutput>


    <!-- Message shown when no results -->
<p id="noResults"
   class="hidden text-center text-gray-500 italic mt-8">
   No orders match your filters.
</p>

  </div>

  <!-- 🔍 Filter Script -->
  <script>
  const searchBox = document.getElementById('searchBox');
  const statusFilter = document.getElementById('statusFilter');
  const clearBtn = document.getElementById('clearFilters');
  const orders = document.querySelectorAll('.orderCard');
  const noResults = document.getElementById('noResults');

  function filterOrders() {
    const search = searchBox.value.toLowerCase();
    const status = statusFilter.value.toLowerCase();

    let visibleCount = 0;

    orders.forEach(card => {
      const orderId = card.dataset.orderid.toLowerCase();
      const customer = card.dataset.customer.toLowerCase();
      const orderStatus = card.dataset.status.toLowerCase();

      const matchesSearch = orderId.includes(search) || customer.includes(search);
      const matchesStatus = !status || orderStatus.includes(status);

      if (matchesSearch && matchesStatus) {
        card.style.display = '';
        visibleCount++;
      } else {
        card.style.display = 'none';
      }
    });

    // 🆕 Toggle no-results message
    noResults.classList.toggle('hidden', visibleCount > 0);
  }

  searchBox.addEventListener('input', filterOrders);
  statusFilter.addEventListener('change', filterOrders);

  // Reset filters
  clearBtn.addEventListener('click', () => {
    searchBox.value = '';
    statusFilter.value = '';
    filterOrders();
  });
</script>
<cfobject component="components.AgentService" name="agentService">

<!--- If Ajax request, return only table HTML and exit --->
<cfif structKeyExists(url, "refresh")>
  <cfset orders = agentService.getAssignedOrders(session.agentid)>
  <cfoutput>
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-800 text-white">
          <tr>
            <th class="px-4 py-2 text-left text-sm font-medium">Order ID</th>
            <th class="px-4 py-2 text-left text-sm font-medium">Customer</th>
            <th class="px-4 py-2 text-left text-sm font-medium">Phone</th>
            <th class="px-4 py-2 text-left text-sm font-medium">Total Items</th>
            <th class="px-4 py-2 text-left text-sm font-medium">Status</th>
            <th class="px-4 py-2 text-left text-sm font-medium">Estimated Delivery</th>
            <th class="px-4 py-2 text-left text-sm font-medium">Created At</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <cfloop query="orders">
            <tr class="hover:bg-gray-50">
              <td class="px-4 py-2 text-sm">#OrderID#</td>
              <td class="px-4 py-2 text-sm">#CustomerName#</td>
              <td class="px-4 py-2 text-sm">#CustomerPhone#</td>
              <td class="px-4 py-2 text-sm">#TotalItems#</td>
              <td class="px-4 py-2 text-sm">
                <cfif Status EQ "Pending">
                  <span class="px-2 py-1 rounded bg-yellow-200 text-yellow-800 font-semibold text-xs">#Status#</span>
                <cfelseif Status EQ "InProgress">
                  <span class="px-2 py-1 rounded bg-blue-200 text-blue-800 font-semibold text-xs">#Status#</span>
                <cfelseif Status EQ "Delivered">
                  <span class="px-2 py-1 rounded bg-green-200 text-green-800 font-semibold text-xs">#Status#</span>
                <cfelse>
                  <span class="px-2 py-1 rounded bg-gray-200 text-gray-800 font-semibold text-xs">#Status#</span>
                </cfif>
              </td>
              <td class="px-4 py-2 text-sm">#dateFormat(EstimatedDeliveryDate, "dd-mmm-yyyy")#</td>
              <td class="px-4 py-2 text-sm">#dateFormat(CreatedAt, "dd-mmm-yyyy")#</td>
            </tr>
          </cfloop>
        </tbody>
      </table>
    </div>
  </cfoutput>
  <cfabort>
</cfif>

<!-- Normal full page load -->
<cfset orders = agentService.getAssignedOrders(session.agentid)>

<!-- Main Content -->
<div class="flex-1 p-8">
  <h2 class="text-2xl font-bold mb-6">Assigned Orders</h2>

  <div id="ordersTable" class="bg-white rounded-2xl shadow p-6 overflow-x-auto">
    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-gray-100 text-gray-700">
        <tr>
          <th class="px-4 py-2 text-left text-sm font-medium">Order ID</th>
          <th class="px-4 py-2 text-left text-sm font-medium">Customer</th>
          <th class="px-4 py-2 text-left text-sm font-medium">Phone</th>
          <th class="px-4 py-2 text-left text-sm font-medium">Total Items</th>
          <th class="px-4 py-2 text-left text-sm font-medium">Status</th>
          <th class="px-4 py-2 text-left text-sm font-medium">Estimated Delivery</th>
          <th class="px-4 py-2 text-left text-sm font-medium">Created At</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-200">
        <cfoutput query="orders">
          <tr class="hover:bg-gray-50">
            <td class="px-4 py-2 text-sm">#OrderID#</td>
            <td class="px-4 py-2 text-sm">#CustomerName#</td>
            <td class="px-4 py-2 text-sm">#CustomerPhone#</td>
            <td class="px-4 py-2 text-sm">#TotalItems#</td>
            <td class="px-4 py-2 text-sm">
              <cfif Status EQ "Pending">
                <span class="px-2 py-1 rounded bg-yellow-200 text-yellow-800 font-semibold text-xs">#Status#</span>
              <cfelseif Status EQ "InProgress">
                <span class="px-2 py-1 rounded bg-blue-200 text-blue-800 font-semibold text-xs">#Status#</span>
              <cfelseif Status EQ "Delivered">
                <span class="px-2 py-1 rounded bg-green-200 text-green-800 font-semibold text-xs">#Status#</span>
              <cfelse>
                <span class="px-2 py-1 rounded bg-gray-200 text-gray-800 font-semibold text-xs">#Status#</span>
              </cfif>
            </td>
            <td class="px-4 py-2 text-sm">#dateFormat(EstimatedDeliveryDate, "dd-mmm-yyyy")#</td>
            <td class="px-4 py-2 text-sm">#dateFormat(CreatedAt, "dd-mmm-yyyy")#</td>
          </tr>
        </cfoutput>
      </tbody>
    </table>
  </div>
</div>

  <script>
    function refreshOrders() {
    $.ajax({
        url: "orders.cfm?refresh=1",
        type: "GET",
        success: function(response) {
            $("#ordersContainer").html($(response).find("#ordersContainer").html());
        }
    });
}
  </script>
</body>
</html>