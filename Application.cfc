<cfcomponent output="false">
  <!-- App settings -->
  <cfset this.name               = "LaundryServiceApp">
  <cfset this.sessionManagement  = true>
  <cfset this.sessionTimeout     = createTimeSpan(0, 2, 0, 0)>
  <cfset this.applicationTimeout = createTimeSpan(1, 0, 0, 0)>
  <cfset this.datasource         = "laundryservice">
  <cfset this.charset            = "UTF-8">
  <cfset this.encoding           = { url="UTF-8", form="UTF-8", request="UTF-8" }>

  <cffunction name="onRequestStart" access="public" returnType="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true">

    <cfscript>
      var basePath = "/laundryservice";
      var page     = lCase(arguments.targetPage);

      // 1) Let static assets through
      if (reFindNoCase("\.(css|js|png|jpg|jpeg|gif|svg|webp|ico|woff2?)$", page)) {
        return true;
      }

      // 2) USER gate (allow login/signup pages)
      if (findNoCase("/pages/user/", page)
          AND NOT findNoCase("/pages/user/login.cfm", page)
          AND NOT findNoCase("/pages/user/signup.cfm", page)) {

        // Accept either session.userid or session.userID (your login may set userID)
        if (NOT (structKeyExists(session, "userid") OR structKeyExists(session, "userID"))) {
          location(url=basePath & "/pages/user/login.cfm", addToken=false);
        }
      }

      // 3) AGENT gate (allow agent login page)
      if (findNoCase("/pages/agent/", page)
          AND NOT findNoCase("/pages/agent/login.cfm", page)) {
        if (NOT structKeyExists(session, "agentid")) {
          location(url=basePath & "/pages/agent/login.cfm", addToken=false);
        }
      }

      // 4) ADMIN gate (allow admin login page)
      if (findNoCase("/pages/admin/", page)
          AND NOT findNoCase("/pages/admin/login.cfm", page)) {
        if (NOT structKeyExists(session, "adminid")) {
          location(url=basePath & "/pages/admin/login.cfm", addToken=false);
        }
      }

      return true;
    </cfscript>
  </cffunction>
</cfcomponent>
