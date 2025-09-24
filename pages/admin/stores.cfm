<!-- stores.cfm -->
<cfif NOT structKeyExists(session, "adminid")>
  <cflocation url="/laundryservice/index.cfm?fuse=admin_login" addtoken="no">
</cfif>

<cfobject component="components.AdminService" name="adminService">

<!-- ========================= CRUD HANDLING ========================= -->

<!-- ✅ ADD STORE -->
<cfif structKeyExists(form, "formAction") AND form.formAction EQ "add">
  <cftry>
    <cfquery datasource="laundryservice">
      INSERT INTO Stores (StoreName, RegionID, Address)
      VALUES (
        <cfqueryparam value="#trim(form.storeName)#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#form.regionID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#trim(form.address)#" cfsqltype="cf_sql_varchar">
      )
    </cfquery>
    <cflocation url="/laundryservice/index.cfm?fuse=admin_stores&message=Store added successfully" addtoken="no">
    <cfcatch>
      <cflocation url="/laundryservice/index.cfm?fuse=admin_stores&error=Error adding store: #cfcatch.message#" addtoken="no">
    </cfcatch>
  </cftry>
</cfif>

<!-- ✏️ EDIT STORE -->
<cfif structKeyExists(form, "formAction") AND form.formAction EQ "edit">
  <cftry>
    <cfquery datasource="laundryservice">
      UPDATE Stores
      SET StoreName = <cfqueryparam value="#trim(form.storeName)#" cfsqltype="cf_sql_varchar">,
          RegionID = <cfqueryparam value="#form.regionID#" cfsqltype="cf_sql_integer">,
          Address = <cfqueryparam value="#trim(form.address)#" cfsqltype="cf_sql_varchar">
      WHERE StoreID = <cfqueryparam value="#form.storeID#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cflocation url="/laundryservice/index.cfm?fuse=admin_stores&message=Store updated successfully" addtoken="no">
    <cfcatch>
      <cflocation url="/laundryservice/index.cfm?fuse=admin_stores&error=Error updating store: #cfcatch.message#" addtoken="no">
    </cfcatch>
  </cftry>
</cfif>

<!-- ❌ DELETE STORE -->
<cfif structKeyExists(url, "deleteID")>
  <cftry>
    <cfquery datasource="laundryservice">
      DELETE FROM Stores WHERE StoreID = <cfqueryparam value="#url.deleteID#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cflocation url="/laundryservice/index.cfm?fuse=admin_stores&message=Store deleted successfully" addtoken="no">
    <cfcatch>
      <cflocation url="/laundryservice/index.cfm?fuse=admin_stores&error=Error deleting store: #cfcatch.message#" addtoken="no">
    </cfcatch>
  </cftry>
</cfif>

<!-- ========================= FETCH DATA ========================= -->
<cfset stores = adminService.getStores()>
<cfset regions = adminService.getRegions()>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Store Management</title>
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
          <li class="nav-item"><a class="nav-link text-white active" href="/laundryservice/index.cfm?fuse=admin_stores">Stores</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_agents">Agents</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_admin_orders">Orders</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_notifications">Notifications</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_reports">Reports</a></li>
          <li class="nav-item"><a class="nav-link text-white" href="/laundryservice/index.cfm?fuse=admin_settings">Settings</a></li>
          <li class="nav-item"><a class="nav-link text-danger" href="/laundryservice/index.cfm?fuse=admin_logout">Logout</a></li>
        </ul>
      </div>

      <!-- Main Content -->
      <div class="col-md-10 p-4">
        <h2 class="mb-4">Manage Stores</h2>

        <!-- ✅ Success/Error Alerts -->
        <cfif structKeyExists(url, "message")>
          <div class="alert alert-success"><cfoutput>#url.message#</cfoutput></div>
        </cfif>
        <cfif structKeyExists(url, "error")>
          <div class="alert alert-danger"><cfoutput>#url.error#</cfoutput></div>
        </cfif>

        <button class="btn btn-primary mb-3" data-bs-toggle="modal" data-bs-target="#addStoreModal">Add Store</button>

        <table class="table table-striped">
          <thead>
            <tr>
              <th>ID</th>
              <th>Store Name</th>
              <th>Region</th>
              <th>Address</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="stores">
              <tr>
                <td>#StoreID#</td>
                <td>#StoreName#</td>
                <td>#RegionID#</td>
                <td>#Address#</td>
                <td>
                  <button class="btn btn-sm btn-warning" onclick="editStore(#StoreID#, '#JSStringFormat(StoreName)#', #RegionID#, '#JSStringFormat(Address)#')">Edit</button>
                  <a href="/laundryservice/index.cfm?fuse=admin_stores&deleteID=#StoreID#" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure?')">Delete</a>
                </td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Add Store Modal -->
  <div class="modal fade" id="addStoreModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Add New Store</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <form method="post" action="/laundryservice/index.cfm?fuse=admin_stores">
          <input type="hidden" name="formAction" value="add">
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Store Name</label>
              <input type="text" name="storeName" class="form-control" required>
            </div>
            <div class="mb-3">
              <label class="form-label">Region</label>
              <select name="regionID" class="form-select" required>
                <cfoutput query="regions">
                  <option value="#RegionID#">#RegionName#</option>
                </cfoutput>
              </select>
            </div>
            <div class="mb-3">
              <label class="form-label">Address</label>
              <textarea name="address" class="form-control" rows="2" required></textarea>
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-primary">Save</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Edit Store Modal -->
  <div class="modal fade" id="editStoreModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Edit Store</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <form method="post" action="/laundryservice/index.cfm?fuse=admin_stores">
          <input type="hidden" name="formAction" value="edit">
          <input type="hidden" name="storeID" id="editStoreID">
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Store Name</label>
              <input type="text" name="storeName" id="editStoreName" class="form-control" required>
            </div>
            <div class="mb-3">
              <label class="form-label">Region</label>
              <select name="regionID" id="editRegionID" class="form-select" required>
                <cfoutput query="regions">
                  <option value="#RegionID#">#RegionName#</option>
                </cfoutput>
              </select>
            </div>
            <div class="mb-3">
              <label class="form-label">Address</label>
              <textarea name="address" id="editAddress" class="form-control" rows="2" required></textarea>
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-success">Update</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <script>
    function editStore(id, name, regionID, address) {
      document.getElementById('editStoreID').value = id;
      document.getElementById('editStoreName').value = name;
      document.getElementById('editRegionID').value = regionID;
      document.getElementById('editAddress').value = address;
      new bootstrap.Modal(document.getElementById('editStoreModal')).show();
    }
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
