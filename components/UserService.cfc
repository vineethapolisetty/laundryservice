<!--- /laundryservice/components/UserService.cfc --->
<cfcomponent output="false">

  <!-- Email/password login -->
  <cffunction name="loginUser" access="public" returnType="query" output="false">
    <cfargument name="email"    type="string" required="true">
    <cfargument name="password" type="string" required="true">
    <cfset var passHash = hash(arguments.password, "SHA-256")>

    <cfquery name="qLogin" datasource="laundryservice">
      SELECT UserID, FullName
      FROM Users
      WHERE Email        = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">
        AND PasswordHash = <cfqueryparam value="#passHash#"        cfsqltype="cf_sql_varchar">
      LIMIT 1
    </cfquery>

    <cfreturn qLogin>
  </cffunction>

  <!-- OPTIONAL HELPERS (safe to keep here) -->

  <cffunction name="signup" access="public" returnType="void" output="false">
    <cfargument name="fullname" type="string" required="true">
    <cfargument name="phone"    type="string" required="true">
    <cfargument name="email"    type="string" required="true">
    <cfargument name="password" type="string" required="true">
    <cfargument name="address"  type="string" required="true">
    <cfset var passHash = hash(arguments.password, "SHA-256")>

    <cfquery datasource="laundryservice">
      INSERT INTO Users (FullName, Phone, Email, PasswordHash, Address, RegionID, CreatedAt)
      VALUES (
        <cfqueryparam value="#arguments.fullname#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#arguments.phone#"    cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#arguments.email#"    cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#passHash#"           cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#arguments.address#"  cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="1"                    cfsqltype="cf_sql_integer">,
        NOW()
      )
    </cfquery>
  </cffunction>

  <cffunction name="getUserIDByPhone" access="public" returnType="string" output="false">
    <cfargument name="phone" type="string" required="true">
    <cfquery name="q" datasource="laundryservice">
      SELECT UserID
      FROM Users
      WHERE Phone = <cfqueryparam value="#arguments.phone#" cfsqltype="cf_sql_varchar">
      LIMIT 1
    </cfquery>
    <cfif q.recordCount EQ 0>
      <cfreturn "">
    <cfelse>
      <cfreturn q.UserID>
    </cfif>
  </cffunction>

  <cffunction name="getProfile" access="public" returnType="query" output="false">
    <cfargument name="userid" type="numeric" required="true">
    <cfquery name="q" datasource="laundryservice">
      SELECT FullName, Email, Phone, Address, ProfileImage
      FROM Users
      WHERE UserID = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
      LIMIT 1
    </cfquery>
    <cfreturn q>
  </cffunction>


    <!--- ===== ADD THESE NEW METHODS (append above </cfcomponent>) ===== --->

  <!--- Update a user's profile. Returns the refreshed profile query. --->
  <cffunction name="updateProfile" access="public" returntype="query" output="false"
              hint="Update FullName, Email, Phone, Address. If AvatarURL column exists it will be updated; otherwise it falls back.">
    <cfargument name="userId"    type="numeric" required="true">
    <cfargument name="fullName"  type="string"  required="true">
    <cfargument name="email"     type="string"  required="false" default="">
    <cfargument name="phone"     type="string"  required="false" default="">
    <cfargument name="avatarURL" type="string"  required="false" default="">
    <cfargument name="address"   type="string"  required="false" default="">

    <!--- First, try updating with AvatarURL (if the column exists). If it fails, retry without it. --->
    <cftry>
      <cfquery datasource="laundryservice">
        UPDATE Users
           SET FullName  = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.fullName#" maxlength="200">,
               Email     = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.email#"   null="#NOT len(arguments.email)#" maxlength="255">,
               Phone     = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.phone#"   null="#NOT len(arguments.phone)#" maxlength="30">,
               Address   = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.address#" null="#NOT len(arguments.address)#" maxlength="500">,
               AvatarURL = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.avatarURL#" null="#NOT len(arguments.avatarURL)#" maxlength="500">
         WHERE UserID    = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userId#">
        LIMIT 1
      </cfquery>
      <cfcatch type="any">
        <!--- Likely no AvatarURL column. Retry without it. --->
        <cfquery datasource="laundryservice">
          UPDATE Users
             SET FullName  = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.fullName#" maxlength="200">,
                 Email     = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.email#"   null="#NOT len(arguments.email)#" maxlength="255">,
                 Phone     = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.phone#"   null="#NOT len(arguments.phone)#" maxlength="30">,
                 Address   = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.address#" null="#NOT len(arguments.address)#" maxlength="500">
           WHERE UserID    = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userId#">
          LIMIT 1
        </cfquery>
      </cfcatch>
    </cftry>

    <!--- Return the refreshed profile using your existing method --->
    <cfreturn getProfile(arguments.userId)>
  </cffunction>

  <!--- Alias that calls updateProfile with the same signature --->
  <cffunction name="saveProfile" access="public" returntype="query" output="false">
    <cfargument name="userId"    type="numeric" required="true">
    <cfargument name="fullName"  type="string"  required="true">
    <cfargument name="email"     type="string"  required="false" default="">
    <cfargument name="phone"     type="string"  required="false" default="">
    <cfargument name="avatarURL" type="string"  required="false" default="">
    <cfargument name="address"   type="string"  required="false" default="">
    <cfreturn updateProfile(argumentCollection=arguments)>
  </cffunction>

  <!--- Accept struct-based updates too (for compatibility with callers that pass a map of fields). --->
  <cffunction name="updateUser" access="public" returntype="query" output="false"
              hint="Update using a struct of fields, e.g., updateUser(userId, {FullName=..., Email=..., Phone=..., Address=..., avatarURL=...})">
    <cfargument name="userId" type="numeric" required="true">
    <cfargument name="data"   type="struct"  required="true">

    <cfset var fn = structKeyExists(arguments.data, "FullName")  ? toString(arguments.data.FullName)  : "">
    <cfset var em = structKeyExists(arguments.data, "Email")     ? toString(arguments.data.Email)     : "">
    <cfset var ph = structKeyExists(arguments.data, "Phone")     ? toString(arguments.data.Phone)     : "">
    <cfset var ad = structKeyExists(arguments.data, "Address")   ? toString(arguments.data.Address)   : "">
    <cfset var av = structKeyExists(arguments.data, "avatarURL") ? toString(arguments.data.avatarURL) : "">

    <cfreturn updateProfile(arguments.userId, fn, em, ph, av, ad)>
  </cffunction>

  <!--- ===== /END ADDED METHODS ===== --->



</cfcomponent>
