<cfprocessingdirective pageEncoding="UTF-8">

<cfif NOT structKeyExists(session, "adminid")>
  <cflocation url="/laundryservice/index.cfm?fuse=admin_login" addtoken="no">
</cfif>

<cfobject component="components.AdminService" name="adminService">
<cfset regions = adminService.getRegions()>
<cfset stores = adminService.getStores()>

<!-- Get filters -->
<cfparam name="form.regionID" default="">
<cfparam name="form.storeID" default="">
<cfparam name="form.status" default="">

<!-- Fetch filtered report -->
<cfset reports = adminService.getOrderReports(regionID=form.regionID, storeID=form.storeID, status=form.status)>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Reports</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
  <div class="container-fluid">
    <div class="row">
      <!-- Sidebar -->
      <div class="col-md-2 bg-dark text-white p-4 min-vh-100">
        <h4 class="text-center">Admin</h4>
        <ul class="nav flex-column mt-4">
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_dashboard">Dashboard</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_regions">Regions</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_stores">Stores</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_agents">Agents</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_admin_orders">Orders</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_notifications">Notifications</a></li>
          <li class="nav-item"><a class="nav-link text-white active" href="/laundryservice/index.cfm?fuse=admin_reports">Reports</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_settings">Settings</a></li>
          <li class="nav-item"><a class="nav-link text-danger" href="/laundryservice/index.cfm?fuse=admin_logout">Logout</a></li>
        </ul>
      </div>

      <!-- Main Content -->
      <div class="col-md-10 p-4">
        <h2 class="mb-4">Order Reports</h2>

        <!-- Filter Form -->
        <form method="post" class="row g-3 mb-4">
          <div class="col-md-3">
            <label class="form-label">Region</label>
            <select class="form-select" name="regionID">
              <option value="">All</option>
              <cfoutput query="regions">
                <option value="#RegionID#" <cfif form.regionID EQ RegionID>selected</cfif>>#RegionName#</option>
              </cfoutput>
            </select>
          </div>

          <div class="col-md-3">
            <label class="form-label">Store</label>
            <select class="form-select" name="storeID">
              <option value="">All</option>
              <cfoutput query="stores">
                <option value="#StoreID#" <cfif form.storeID EQ StoreID>selected</cfif>>#StoreName#</option>
              </cfoutput>
            </select>
          </div>

          <div class="col-md-3">
            <label class="form-label">Status</label>
            <select class="form-select" name="status">
              <option value="">All</option>
              <option value="Pending" <cfif form.status EQ "Pending">selected</cfif>>Pending</option>
              <option value="Delivered" <cfif form.status EQ "Delivered">selected</cfif>>Delivered</option>
              <option value="Cancelled" <cfif form.status EQ "Cancelled">selected</cfif>>Cancelled</option>
            </select>
          </div>

          <div class="col-md-3 align-self-end">
            <button class="btn btn-primary w-100">Filter</button>
          </div>
        </form>

        <!-- Report Table -->
        <table class="table table-bordered table-hover">
          <thead class="table-light">
            <tr>
              <th>Order ID</th>
              <th>Status</th>
              <th>Total Items</th>
              <th>Estimated Cost</th>
              <th>Store</th>
              <th>Region</th>
              <th>User</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="reports">
              <tr>
                <td>#OrderID#</td>
                <td>#Status#</td>
                <td>#TotalItems#</td>
                <td>₹#NumberFormat(TotalEstimatedCost, "999,999.00")#</td>
                <td>#StoreName#</td>
                <td>#RegionName#</td>
                <td>#FullName#</td>
                <td>#dateFormat(CreatedAt, "dd-mmm-yyyy")#</td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</body>
</html>
