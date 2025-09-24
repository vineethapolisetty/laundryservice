<cfif NOT structKeyExists(session, "adminid")>
  <cflocation url="/laundryservice/index.cfm?fuse=admin_login" addtoken="no">
</cfif>

<cfobject component="components.AdminService" name="adminService">
<cfset adminDetails = adminService.getAdminByID(session.adminid)>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Settings</title>
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
        <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_reports">Reports</a></li>
        <li class="nav-item"><a class="nav-link text-white active" href="/laundryservice/index.cfm?fuse=admin_settings">Settings</a></li>
        <li class="nav-item"><a class="nav-link text-danger" href="/laundryservice/index.cfm?fuse=admin_logout">Logout</a></li>
      </ul>
    </div>

    <!-- Main Content -->
    <div class="col-md-10 p-4">
      <h2 class="mb-4">Admin Settings</h2>

      <cfoutput>
  <!-- post to router so router includes pages/admin/update_profile.cfm -->
  <form method="post" action="/laundryservice/index.cfm?fuse=admin_update_profile" class="row g-3">
    <!-- optional: keep adminID hidden, but server uses session.adminID in update_profile.cfm -->
    <input type="hidden" name="adminID" value="#adminDetails.AdminID#">

    <div class="col-md-6">
      <label class="form-label">Full Name</label>
      <!-- name must match what update_profile.cfm expects: fullName -->
      <input type="text" name="fullName" class="form-control" value="#adminDetails.FullName#" required>
    </div>

    <div class="col-md-6">
      <label class="form-label">Email</label>
      <input type="email" name="email" class="form-control" value="#adminDetails.Email#" required>
    </div>

    <div class="col-md-4">
      <label class="form-label">Role</label>
      <input type="text" name="role" class="form-control" value="#adminDetails.Role#" readonly>
    </div>

    <div class="col-md-4">
      <label class="form-label">Region ID</label>
      <input type="text" name="regionID" class="form-control" value="#adminDetails.RegionID#" readonly>
    </div>

    <div class="col-md-12">
      <hr>
      <h5 class="mb-3">Change Password</h5>
    </div>

    <div class="col-md-6">
      <label class="form-label">New Password</label>
      <input type="password" name="newPassword" class="form-control">
    </div>

    <div class="col-md-6">
      <label class="form-label">Confirm Password</label>
      <input type="password" name="confirmPassword" class="form-control">
    </div>

    <div class="col-12">
      <button type="submit" class="btn btn-primary">Update Profile</button>
    </div>
  </form>
</cfoutput>

    </div>
  </div>
</div>
</body>
</html>
