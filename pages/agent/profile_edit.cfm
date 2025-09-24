<cfif NOT structKeyExists(session, "agentid")>
  <cflocation url="/laundryservice/index.cfm?fuse=agent_login">
</cfif>

<cfobject component="components.AgentService" name="agentService">

<cfif structKeyExists(form, "submit")>
  <!-- Save updated profile -->
  <cfquery datasource="laundryservice">
    UPDATE Agents
    SET 
      FullName = <cfqueryparam value="#form.FullName#" cfsqltype="cf_sql_varchar">,
      Email    = <cfqueryparam value="#form.Email#" cfsqltype="cf_sql_varchar">,
      Phone    = <cfqueryparam value="#form.Phone#" cfsqltype="cf_sql_varchar">
    WHERE AgentID = <cfqueryparam value="#session.agentid#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cflocation url="/laundryservice/index.cfm?fuse=agent_profile">
</cfif>

<!-- Load profile -->
<cfset profile = agentService.getProfile(session.agentid)>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Edit Profile</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-50 p-6 font-sans">
  <div class="max-w-md mx-auto bg-white p-6 rounded-xl shadow">
    <h1 class="text-xl font-bold mb-4">Edit Profile</h1>
    <form method="post">
      <div class="mb-4">
        <label class="block text-gray-600 text-sm mb-1">Full Name</label>
        <input type="text" name="FullName" value="<cfoutput>#encodeForHTML(profile.FullName)#</cfoutput>" class="w-full border rounded p-2">
      </div>
      <div class="mb-4">
        <label class="block text-gray-600 text-sm mb-1">Email</label>
        <input type="email" name="Email" value="<cfoutput>#encodeForHTML(profile.Email)#</cfoutput>" class="w-full border rounded p-2">
      </div>
      <div class="mb-4">
        <label class="block text-gray-600 text-sm mb-1">Phone</label>
        <input type="text" name="Phone" value="<cfoutput>#encodeForHTML(profile.Phone)#</cfoutput>" class="w-full border rounded p-2">
      </div>
      <button type="submit" name="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
        Save Changes
      </button>
      <a href="/laundryservice/index.cfm?fuse=agent_profile" class="ml-2 text-gray-600 hover:underline">Cancel</a>
    </form>
  </div>
</body>
</html>
