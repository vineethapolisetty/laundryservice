<!-- dashboard.cfm -->
<cfif NOT structKeyExists(session, "adminid")>
  <cflocation url="/laundryservice/index.cfm?fuse=admin_login" addtoken="no">
</cfif>

<cfobject component="components.AdminService" name="adminService">
<cfset stats = adminService.getDashboardStats(session.adminid, session.adminrole)>
<cfset recentOrders = adminService.getRecentOrders(session.adminid, session.adminrole)>
<cfset requestsByRegion = adminService.getRequestsByRegion()>
<cfset storePerformance = adminService.getStorePerformance()>
<cfset agentPerformance = adminService.getAgentPerformance()>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Dashboard</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="bg-light">
  <div class="container-fluid">
    <div class="row">
      <div class="col-md-2 bg-dark text-white p-4 min-vh-100">
        <h4 class="text-center">Admin</h4>
        <ul class="nav flex-column mt-4">
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_dashboard">Dashboard</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_regions">Regions</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_stores">Stores</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_agents">Agents</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_admin_orders">Orders</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_notifications">Notifications</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_reports">Reports</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_settings">Settings</a></li>
          <li class="nav-item"><a class="nav-link text-danger" href="/laundryservice/index.cfm?fuse=admin_logout">Logout</a></li>
        </ul>
      </div>
      <div class="col-md-10 p-4">
        <h2>Welcome, <cfoutput>#session.adminname# !</cfoutput></h2>
        <div class="row my-4">
          <div class="col">
            <div class="card text-center">
              <div class="card-body">
                <h5>Total Regions</h5>
                <h3><cfoutput>#stats.totalRegions#</cfoutput></h3>
              </div>
            </div>
          </div>
          <div class="col">
            <div class="card text-center">
              <div class="card-body">
                <h5>Active Stores</h5>
                <h3><cfoutput>#stats.totalStores#</cfoutput></h3>
              </div>
            </div>
          </div>
          <div class="col">
            <div class="card text-center">
              <div class="card-body">
                <h5>Active Agents</h5>
                <h3><cfoutput>#stats.totalAgents#</cfoutput></h3>
              </div>
            </div>
          </div>
          <div class="col">
            <div class="card text-center">
              <div class="card-body">
                <h5>Total Orders</h5>
                <h3><cfoutput>#stats.totalOrders#</cfoutput></h3>
              </div>
            </div>
          </div>
          
        </div>

        <!-- Recent Orders -->
        <h4 class="mt-5">Recent Orders</h4>
        <table class="table table-bordered">
          <thead>
            <tr>
              <th>Order ID</th>
              <th>User</th>
              <th>Store</th>
              <th>Region</th>
              <th>Status</th>
              <th>Created At</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="recentOrders">
              <tr>
                <td>#OrderID#</td>
                <td>#FullName#</td>
                <td>#StoreName#</td>
                <td>#RegionName#</td>
                <td>#Status#</td>
                <td>#dateFormat(CreatedAt, 'yyyy-mm-dd')#</td>
              </tr>
            </cfoutput>
          </tbody>
        </table>

        <!-- Charts Placeholder -->
        <div class="row mt-5">
          <div class="col-md-6">
            <canvas id="regionChart"></canvas>
          </div>
          <div class="col-md-6">
            <canvas id="storeChart"></canvas>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script>
    const regionChart = document.getElementById('regionChart').getContext('2d');
    new Chart(regionChart, {
      type: 'bar',
      data: {
        labels: [<cfoutput query="requestsByRegion">"#RegionName#"<cfif currentRow LT recordCount>,</cfif></cfoutput>],
        datasets: [{
          label: 'Orders',
          data: [<cfoutput query="requestsByRegion">#OrderCount#<cfif currentRow LT recordCount>,</cfif></cfoutput>],
          backgroundColor: 'rgba(54, 162, 235, 0.5)'
        }]
      }
    });

    const storeChart = document.getElementById('storeChart').getContext('2d');
    new Chart(storeChart, {
      type: 'bar',
      data: {
        labels: [<cfoutput query="storePerformance">"#StoreName#"<cfif currentRow LT recordCount>,</cfif></cfoutput>],
        datasets: [{
          label: 'Total Orders',
          data: [<cfoutput query="storePerformance">#TotalOrders#<cfif currentRow LT recordCount>,</cfif></cfoutput>],
          backgroundColor: 'rgba(75, 192, 192, 0.5)'
        }]
      }
    });
  </script>
</body>
</html>
