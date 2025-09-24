<!-- agents.cfm -->
<cfif NOT structKeyExists(session, "adminid")>
  <cflocation url="/laundryservice/index.cfm?fuse=admin_login" addtoken="no">
</cfif>

<cfobject component="components.AdminService" name="adminService">

<!-- ========================= ADD NEW AGENT ========================= -->
<cfif structKeyExists(form, "fullname") AND structKeyExists(form, "email")>
    <cftry>
        <cfquery datasource="laundryservice">
            INSERT INTO Agents (FullName, Email, Phone, Status, CreatedAt)
            VALUES (
                <cfqueryparam value="#form.fullname#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.phone#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.status#" cfsqltype="cf_sql_varchar">,
                NOW()
            )
        </cfquery>
        <cflocation url="/laundryservice/index.cfm?fuse=admin_agents&message=Agent added successfully" addtoken="no">
        <cfcatch>
            <cflocation url="/laundryservice/index.cfm?fuse=admin_agents&error=Error adding agent: #cfcatch.message#" addtoken="no">
        </cfcatch>
    </cftry>
</cfif>

<!-- ========================= STATUS TOGGLE HANDLING ========================= -->
<cfif structKeyExists(url, "toggleID") AND structKeyExists(url, "action")>
  <cftry>
    <cfif url.action EQ "disable">
      <cfquery datasource="laundryservice">
        UPDATE Agents
        SET Status = 'Inactive'
        WHERE AgentID = <cfqueryparam value="#url.toggleID#" cfsqltype="cf_sql_integer">
      </cfquery>
      <cflocation url="/laundryservice/index.cfm?fuse=admin_agents&message=Agent disabled successfully" addtoken="no">
    <cfelseif url.action EQ "enable">
      <cfquery datasource="laundryservice">
        UPDATE Agents
        SET Status = 'Active'
        WHERE AgentID = <cfqueryparam value="#url.toggleID#" cfsqltype="cf_sql_integer">
      </cfquery>
      <cflocation url="/laundryservice/index.cfm?fuse=admin_agents&message=Agent enabled successfully" addtoken="no">
    </cfif>
    <cfcatch>
      <cflocation url="/laundryservice/index.cfm?fuse=admin_agents&error=Error updating agent: #cfcatch.message#" addtoken="no">
    </cfcatch>
  </cftry>
</cfif>

<!-- ========================= FETCH AGENTS ========================= -->
<cfset agents = adminService.getAgents()>


<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Agents Management</title>
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
          <li class="nav-item"><a class="nav-link text-white active" href="/laundryservice/index.cfm?fuse=admin_agents">Agents</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_admin_orders">Orders</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_notifications">Notifications</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_reports">Reports</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_settings">Settings</a></li>
          <li class="nav-item"><a class="nav-link text-danger" href="/laundryservice/index.cfm?fuse=admin_logout">Logout</a></li>
        </ul>
      </div>

      <!-- Main -->
      <div class="col-md-10 p-4">
        <h2 class="mb-4">Manage Agents</h2>

        <!-- ✅ Success/Error Alerts -->
        <cfif structKeyExists(url, "message")>
          <div class="alert alert-success"><cfoutput>#url.message#</cfoutput></div>
        </cfif>
        <cfif structKeyExists(url, "error")>
          <div class="alert alert-danger"><cfoutput>#url.error#</cfoutput></div>
        </cfif>

        <table class="table table-bordered">
          <thead class="table-light">
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Email</th>
              <th>Phone</th>
              <th>Status</th>
              <th>Created</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="agents">
              <tr>
                <td>#AgentID#</td>
                <td>#FullName#</td>
                <td>#Email#</td>
                <td>#Phone#</td>
                <td>
                  <cfif Status EQ "Active">
                    <span class="badge bg-success">Active</span>
                  <cfelse>
                    <span class="badge bg-secondary">Inactive</span>
                  </cfif>
                </td>
                <td>#dateFormat(CreatedAt, "dd-mmm-yyyy")#</td>
                <td>
                  <cfif Status EQ "Active">
                    <a href="/laundryservice/index.cfm?fuse=admin_agents&toggleID=#AgentID#&action=disable" class="btn btn-sm btn-danger" onclick="return confirm('Disable this agent?')">Disable</a>
                  <cfelse>
                    <a href="/laundryservice/index.cfm?fuse=admin_agents&toggleID=#AgentID#&action=enable" class="btn btn-sm btn-success" onclick="return confirm('Enable this agent?')">Enable</a>
                  </cfif>
                </td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
