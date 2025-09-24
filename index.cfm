<!--- index.cfm (router-aware) ---> 
<cfscript>
/* Detect route token (query or PATH_INFO) */
hasFuse = (structKeyExists(url,'fuse') and len(trim(url.fuse))) or (structKeyExists(cgi,'PATH_INFO') and len(trim(cgi.PATH_INFO)));
</cfscript>

<cfif hasFuse>
  <!-- Hand control to router -->
  <cfinclude template="router.cfm">
  <cfabort>
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Laundry Service Portal</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="/laundryservice/assets/css/laundryservice_index_cfm.styles.css">
  <style>
    /* tiny inline helper so the demo looks nice if css missing */
    .container{display:flex;gap:24px;padding:40px}
    .card{flex:1;background:#fff;border-radius:10px;padding:30px;box-shadow:0 6px 18px rgba(0,0,0,.06);text-align:center}
    .button{display:inline-block;margin-top:18px;padding:10px 18px;background:#007bff;color:#fff;border-radius:8px;text-decoration:none}
  </style>
</head>
<body>
  <h1 style="text-align:center;margin-top:28px">👕 Laundry Service Portal</h1>

  <div class="container">
    <div class="card">
      <h2>🧍‍♂️ User</h2>
      <p>Book laundry, track orders, and manage your profile.</p>
      <!-- absolute link to index.cfm router (recommended) -->
      <a class="button" href="/laundryservice/index.cfm?fuse=login">User Login</a>
    </div>

    <div class="card">
      <h2>🧑‍💼 Agent</h2>
      <p>View pickups, deliveries and update order status.</p>
      <!-- note: use agent_login if your router defines that key -->
      <a class="button" href="/laundryservice/index.cfm?fuse=agent_login">Agent Login</a>
    </div>

    <div class="card">
      <h2>🧑‍💻 Admin</h2>
      <p>Manage regions, stores, agents, and view reports.</p>
      <!-- note: use admin_login if your router defines that key -->
      <a class="button" href="/laundryservice/index.cfm?fuse=admin_login">Admin Login</a>
    </div>
  </div>
</body>
</html>
