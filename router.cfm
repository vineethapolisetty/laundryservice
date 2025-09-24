<!--- router.cfm (recommended improved version) --->

<cfparam name="url.fuse" default="">
<cfset fuse = lcase(trim(url.fuse))>

<!-- If PATH_INFO is used (pretty URLs), prefer that when no query fuse -->
<cfif NOT len(fuse) AND structKeyExists(cgi, "PATH_INFO") AND len(trim(cgi.PATH_INFO))>
  <cfset fuse = trim(cgi.PATH_INFO)>
  <cfif left(fuse,1) EQ "/">
    <cfset fuse = right(fuse, len(fuse)-1)>
  </cfif>
</cfif>

<!-- Normalize: convert slashes to underscores so both 'agent/login' and 'agent_login' work -->
<cfset fuse = replace(fuse, "/", "_", "all")>

<!-- Default landing -->
<cfif NOT len(fuse)>
  <cfset fuse = "dashboard">
</cfif>

<!-- Helper: safe include that returns 404 if template missing -->
<cffunction name="safeInclude" access="public" returntype="void" output="true">
  <cfargument name="templatePath" type="string" required="true">

  <cfset var full = expandPath(arguments.templatePath)>

  <cfif NOT fileExists(full)>
    <cfheader statusCode="404" statusText="Not Found">
    <cfif fileExists(expandPath("pages/_errors/404.cfm"))>
      <cfinclude template="pages/_errors/404.cfm">
    <cfelse>
      <cfoutput><h1>404 Not Found</h1><p>The requested route '#encodeForHTML(fuse)#' was not found.</p></cfoutput>
    </cfif>
    <cfabort>
  </cfif>

  <!--- ✅ include using the relative path, not the expanded variable --->
  <cfinclude template="#arguments.templatePath#">
</cffunction>


<!--- ROUTES --->
<!-- User pages -->
<cfif fuse eq "login">
  <cfset safeInclude("pages/user/login.cfm")>

<cfelseif fuse eq "dashboard">
  <cfset safeInclude("pages/user/dashboard.cfm")>

<cfelseif fuse eq "bookorder">
  <cfset safeInclude("pages/user/bookOrder.cfm")>

<cfelseif fuse eq "cancelorder">
  <cfset safeInclude("pages/user/cancelOrder.cfm")>

<cfelseif fuse eq "change_password">
  <cfset safeInclude("pages/user/change_password.cfm")>

<cfelseif fuse eq "confirm_otp">
  <cfset safeInclude("pages/user/confirm_otp.cfm")>

<cfelseif fuse eq "createorder">
  <cfset safeInclude("pages/user/createOrder.cfm")>

<cfelseif fuse eq "email_login">
  <cfset safeInclude("pages/user/email_login.cfm")>

<cfelseif fuse eq "magic_login">
  <cfset safeInclude("pages/user/magic_login.cfm")>

<cfelseif fuse eq "notifications">
  <cfset safeInclude("pages/user/notifications.cfm")>

<cfelseif fuse eq "orderdetails">
  <cfset safeInclude("pages/user/orderDetails.cfm")>

<cfelseif fuse eq "orderhistory">
  <cfset safeInclude("pages/user/orderHistory.cfm")>

<cfelseif fuse eq "orderstatus">
  <cfset safeInclude("pages/user/orderStatus.cfm")>

<cfelseif fuse eq "payment_add">
  <cfset safeInclude("pages/user/payment_add.cfm")>

<cfelseif fuse eq "profile_edit">
  <cfset safeInclude("pages/user/profile_edit.cfm")>

<cfelseif fuse eq "profile_upload">
  <cfset safeInclude("pages/user/profile_upload.cfm")>

<cfelseif fuse eq "profile">
  <cfset safeInclude("pages/user/profile.cfm")>

<cfelseif fuse eq "reorder">
  <cfset safeInclude("pages/user/reorder.cfm")>

<cfelseif fuse eq "signup">
  <cfset safeInclude("pages/user/signup.cfm")>

<cfelseif fuse eq "supportchat">
  <cfset safeInclude("pages/user/supportChat.cfm")>

<cfelseif fuse eq "verify_phone">
  <cfset safeInclude("pages/user/verify_phone.cfm")>

<cfelseif fuse eq "privacy">
  <cfset safeInclude("pages/user/privacy.cfm")>

<cfelseif fuse eq "logout">
  <cfset safeInclude("pages/user/logout.cfm")>


<!-- Agent pages -->
<cfelseif fuse eq "agent_orders">
  <cfset safeInclude("pages/agent/orders.cfm")>

<cfelseif fuse eq "agent_change_password">
  <cfset safeInclude("pages/agent/change_password.cfm")>

<cfelseif fuse eq "agent_dashboard">
  <cfset safeInclude("pages/agent/dashboard.cfm")>

<cfelseif fuse eq "agent_login">
  <cfset safeInclude("pages/agent/login.cfm")>

<cfelseif fuse eq "agent_logout">
  <cfset safeInclude("pages/agent/logout.cfm")>

<cfelseif fuse eq "agent_orderdetails">
  <cfset safeInclude("pages/agent/orderDetails.cfm")>

<cfelseif fuse eq "agent_profile_edit">
  <cfset safeInclude("pages/agent/profile_edit.cfm")>

<cfelseif fuse eq "agent_profile_upload">
  <cfset safeInclude("pages/agent/profile_upload.cfm")>

<cfelseif fuse eq "agent_profile">
  <cfset safeInclude("pages/agent/profile.cfm")>

<cfelseif fuse eq "agent_tracker">
  <cfset safeInclude("pages/agent/tracker.cfm")>


<!-- Admin pages -->
<cfelseif fuse eq "admin_admin_orders">
  <cfset safeInclude("pages/admin/admin_orders.cfm")>

<cfelseif fuse eq "admin_agents">
  <cfset safeInclude("pages/admin/agents.cfm")>

<cfelseif fuse eq "admin_dashboard">
  <cfset safeInclude("pages/admin/dashboard.cfm")>

<cfelseif fuse eq "admin_login">
  <cfset safeInclude("pages/admin/login.cfm")>

<cfelseif fuse eq "admin_logout">
  <cfset safeInclude("pages/admin/logout.cfm")>

<cfelseif fuse eq "admin_notifications">
  <cfset safeInclude("pages/admin/notifications.cfm")>

<cfelseif fuse eq "admin_regions">
  <cfset safeInclude("pages/admin/regions.cfm")>

<cfelseif fuse eq "admin_reports">
  <cfset safeInclude("pages/admin/reports.cfm")>

<cfelseif fuse eq "admin_settings">
  <cfset safeInclude("pages/admin/settings.cfm")>

<cfelseif fuse eq "admin_stores">
  <cfset safeInclude("pages/admin/stores.cfm")>

<cfelseif fuse eq "admin_update_profile">
    <cfset safeInclude("pages/admin/update_profile.cfm")>



<!-- Unknown route -> 404 -->
<cfelse>
  <cfheader statusCode="404" statusText="Not Found">
  <cfif fileExists(expandPath("pages/_errors/404.cfm"))>
    <cfinclude template="pages/_errors/404.cfm">
  <cfelse>
    <cfoutput><h1>404 Not Found</h1><p>The requested page was not found.</p></cfoutput>
  </cfif>
</cfif>
