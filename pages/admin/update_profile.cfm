<!--- /pages/admin/update_profile.cfm --->

<cfset updateMsg = "">

<!--- Handle form submission --->
<cfif structKeyExists(form, "fullName")>
  <cftry>
    <cfquery datasource="laundryservice">
      UPDATE Admins
      SET 
        FullName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.fullName#">,
        Email    = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">,
      WHERE AdminID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.adminID#">
    </cfquery>
    <cfset updateMsg = "Profile updated successfully.">
  <cfcatch type="any">
    <cfset updateMsg = "Error updating profile: #encodeForHTML(cfcatch.message)#">
  </cfcatch>
  </cftry>
</cfif>

<!--- Load current profile info --->
<cfquery name="qAdmin" datasource="laundryservice">
  SELECT AdminID, FullName, Email
  FROM Admins
  WHERE AdminID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.adminID#">
</cfquery>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Profile</title>
  <link rel="stylesheet" href="/laundryservice/assets/css/per_page/laundryservice_page_admin_update_profile_style.css">
</head>
<body>
  <div class="profile-container">
    <h1> Update Profile</h1>

    <cfif len(updateMsg)>
      <div class="alert">
        <cfoutput>#updateMsg#</cfoutput>
      </div>
    </cfif>

    <cfoutput query="qAdmin">
      <form method="post" action="/laundryservice/index.cfm?fuse=admin_update_profile" id="profileForm">
        <div class="form-group">
          <label>Full Name</label>
          <input type="text" name="fullName" value="#encodeForHTML(FullName)#" required>
        </div>

        <div class="form-group">
          <label>Email</label>
          <input type="email" name="email" value="#encodeForHTML(Email)#" required>
        </div>

        <button type="submit" class="btn">Save Changes</button>
      </form>
    </cfoutput>
  </div>

  <script src="/laundryservice/assets/js/per_page/laundryservice_page_admin_update_profile_script.js"></script>
</body>
</html>
