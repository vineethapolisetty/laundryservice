<cfcomponent output="false" hint="Handles magic link creation & consumption">

  <cffunction name="createAndEmailLink" access="public" returntype="struct" output="false" hint="Create a single-use login link and email it">
    <cfargument name="email" type="string" required="true">
    <cfset var resp   = { ok=false, message="", email=trim(arguments.email) }>
    <cfset var qUser  = "" />
    <cfset var token  = "" />
    <cfset var baseUrl= "" />
    <cfset var loginUrl = "" />

    <cftry>
      <!-- Find the user -->
      <cfquery name="qUser" datasource="laundryservice">
        SELECT UserID, FullName, Email
        FROM Users
        WHERE Email = <cfqueryparam value="#resp.email#" cfsqltype="cf_sql_varchar">
        LIMIT 1
      </cfquery>

      <cfif qUser.recordCount EQ 0>
        <cfset resp.message = "No account found for that email.">
        <cfreturn resp>
      </cfif>

      <!-- Secure random token (64 chars) -->
      <cfset token = lcase( replace( hash( createUUID() & getTickCount() & randRange(100000,999999), "SHA-256"), "-", "", "all") )>

      <!-- Store token (15 min expiry) -->
      <cfquery datasource="laundryservice">
        INSERT INTO UserMagicLinks (UserID, Token, ExpiresAt)
        VALUES (
          <cfqueryparam value="#qUser.UserID#" cfsqltype="cf_sql_integer">,
          <cfqueryparam value="#token#" cfsqltype="cf_sql_varchar">,
          DATE_ADD(NOW(), INTERVAL 15 MINUTE)
        )
      </cfquery>

      <!-- Build absolute URL -->
      <cfset baseUrl  = "https://" & cgi.server_name & "/laundryservice/pages/user">
      <cfif cgi.server_port NEQ "443" AND cgi.server_port NEQ "80">
        <cfset baseUrl = baseUrl & ":" & cgi.server_port>
      </cfif>
      <cfset loginUrl = baseUrl & "/magic_login.cfm?token=" & urlEncodedFormat(token)>

      <!-- Send email (requires mail server configured in CF Admin) -->
      <cfmail to="#qUser.Email#" from="no-reply@yourdomain.com"
              subject="Your LaundryLink sign-in link"
              type="html">
        <p>Hi <strong>#encodeForHTML(qUser.FullName)#</strong>,</p>
        <p>Use the button below to sign in. This link expires in 15 minutes and can be used once.</p>
        <p>
          <a href="#loginUrl#" style="display:inline-block;background:#4f46e5;color:#fff;
             padding:10px 14px;border-radius:8px;text-decoration:none;font-weight:bold">
             Sign in to LaundryLink
          </a>
        </p>
        <p>If the button doesn’t work, copy & paste this URL:<br>
          <a href="#loginUrl#">#loginUrl#</a>
        </p>
      </cfmail>

      <cfset resp.ok = true>
      <cfset resp.message = "We emailed a sign-in link to #qUser.Email#.">
      <cfreturn resp>

      <cfcatch>
        <cfset resp.message = "Could not send login link: #cfcatch.message#">
        <cfreturn resp>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="consumeToken" access="public" returntype="struct" output="false" hint="Validate token and return user for login">
    <cfargument name="token" type="string" required="true">
    <cfset var resp  = { ok=false, message="", userID=0, fullName="" } />
    <cfset var q     = "" />

    <cftry>
      <cfquery name="q" datasource="laundryservice">
        SELECT m.MagicID, m.UserID, u.FullName, m.ExpiresAt, m.UsedAt
        FROM UserMagicLinks m
        JOIN Users u ON u.UserID = m.UserID
        WHERE m.Token = <cfqueryparam value="#trim(arguments.token)#" cfsqltype="cf_sql_varchar">
        LIMIT 1
      </cfquery>

      <cfif q.recordCount EQ 0>
        <cfset resp.message = "Invalid link.">
        <cfreturn resp>
      </cfif>

      <cfif NOT isNull(q.UsedAt)>
        <cfset resp.message = "This link was already used.">
        <cfreturn resp>
      </cfif>

      <cfif now() GT q.ExpiresAt>
        <cfset resp.message = "This link has expired.">
        <cfreturn resp>
      </cfif>

      <!-- Mark as used -->
      <cfquery datasource="laundryservice">
        UPDATE UserMagicLinks
           SET UsedAt = NOW()
         WHERE MagicID = <cfqueryparam value="#q.MagicID#" cfsqltype="cf_sql_integer">
      </cfquery>

      <cfset resp.ok = true>
      <cfset resp.userID = q.UserID>
      <cfset resp.fullName = q.FullName>
      <cfreturn resp>

      <cfcatch>
        <cfset resp.message = "Token validation failed: #cfcatch.message#">
        <cfreturn resp>
      </cfcatch>
    </cftry>
  </cffunction>

</cfcomponent>
