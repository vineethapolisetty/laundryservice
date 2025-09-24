<cfif NOT structKeyExists(session, "agentid")>
  <cflocation url="/laundryservice/index.cfm?fuse=agent_login">
</cfif>

<cfif structKeyExists(form, "submit")>
  <!-- basic validation -->
  <cfif form.newPassword NEQ form.confirmPassword>
    <cfset error = "Passwords do not match.">
  <cfelse>
    <!-- hash the password (you can switch to bcrypt/Argon2 in real apps) -->
    <cfset hashed = hash(form.newPassword, "SHA-256")>

    <cfquery datasource="laundryservice">
      UPDATE Agents
      SET PasswordHash = <cfqueryparam value="#hashed#" cfsqltype="cf_sql_varchar">
      WHERE AgentID = <cfqueryparam value="#session.agentid#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cflocation url="/laundryservice/index.cfm?fuse=agent_profile">
  </cfif>
</cfif>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Change Password</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-50 p-6 font-sans">
  <div class="max-w-md mx-auto bg-white p-6 rounded-xl shadow">
    <h1 class="text-xl font-bold mb-4">Change Password</h1>

    <cfif structKeyExists(variables, "error")>
      <p class="bg-red-100 text-red-700 px-3 py-2 rounded mb-4"><cfoutput>#error#</cfoutput></p>
    </cfif>

    <form method="post">
      <div class="mb-4">
        <label class="block text-gray-600 text-sm mb-1">New Password</label>
        <input type="password" name="newPassword" required class="w-full border rounded p-2">
      </div>
      <div class="mb-4">
        <label class="block text-gray-600 text-sm mb-1">Confirm Password</label>
        <input type="password" name="confirmPassword" required class="w-full border rounded p-2">
      </div>
      <button type="submit" name="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
        Update Password
      </button>
      <a href="/laundryservice/index.cfm?fuse=agent_profile" class="ml-2 text-gray-600 hover:underline">Cancel</a>
    </form>
  </div>
</body>
</html>
