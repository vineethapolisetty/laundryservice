<cfcomponent>

  <!-- Admin Login -->
  <cffunction name="loginAdmin" access="public" returntype="query">
    <cfargument name="email" required="true">
    <cfargument name="password" required="true">

    <cfquery name="q" datasource="laundryservice">
      SELECT AdminID, FullName, Role, RegionID
      FROM Admins
      WHERE Email = <cfqueryparam value="#arguments.email#">
        AND PasswordHash = <cfqueryparam value="#hash(arguments.password, 'SHA-256')#">
    </cfquery>

    <cfreturn q>
  </cffunction>

  <!-- 📊 Dashboard Stats -->
  <cffunction name="getDashboardStats" access="public" returntype="struct">
    <cfargument name="adminID" required="true">
    <cfargument name="adminRole" required="true">
    <cfset stats = {}>

    <cfquery name="orders" datasource="laundryservice">
      SELECT COUNT(*) AS totalOrders FROM Orders
    </cfquery>
    <cfset stats.totalOrders = orders.totalOrders>

    <cfquery name="regions" datasource="laundryservice">
      SELECT COUNT(*) AS totalRegions FROM Regions
    </cfquery>
    <cfset stats.totalRegions = regions.totalRegions>

    <cfquery name="stores" datasource="laundryservice">
      SELECT COUNT(*) AS totalStores FROM Stores
    </cfquery>
    <cfset stats.totalStores = stores.totalStores>

    <cfquery name="agents" datasource="laundryservice">
      SELECT COUNT(*) AS totalAgents FROM Agents
    </cfquery>
    <cfset stats.totalAgents = agents.totalAgents>

    <cfreturn stats>
  </cffunction>

  <!-- 📋 Recent Orders -->
  <cffunction name="getRecentOrders" access="public" returntype="query">
    <cfargument name="adminID" required="true">
    <cfargument name="adminRole" required="true">

    <cfquery name="q" datasource="laundryservice">
      SELECT o.OrderID, o.Status, o.CreatedAt, u.FullName, s.StoreName, r.RegionName
      FROM Orders o
      JOIN Users u ON o.UserID = u.UserID
      JOIN Stores s ON o.StoreID = s.StoreID
      JOIN Regions r ON s.RegionID = r.RegionID
      ORDER BY o.CreatedAt DESC
      LIMIT 10
    </cfquery>

    <cfreturn q>
  </cffunction>

  <!-- 🔔 Notifications -->
  <cffunction name="getNotifications" access="public" returntype="query">
    <cfquery name="q" datasource="laundryservice">
      SELECT n.NotificationID, n.Message, n.IsRead, n.SentAt, u.FullName, n.OrderID
      FROM Notifications n
      JOIN Users u ON n.UserID = u.UserID
      ORDER BY n.SentAt DESC
    </cfquery>
    <cfreturn q>
  </cffunction>

  <!-- 👤 Admins -->
  <cffunction name="getAdmins" access="public" returntype="query">
    <cfquery name="q" datasource="laundryservice">
      SELECT a.AdminID, a.FullName, a.Email, a.Role, a.CreatedAt, r.RegionName
      FROM Admins a
      LEFT JOIN Regions r ON a.RegionID = r.RegionID
    </cfquery>
    <cfreturn q>
  </cffunction>

  <!-- 🌍 Regions -->
  <cffunction name="getRegions" access="public" returntype="query">
    <cfquery name="q" datasource="laundryservice">
      SELECT RegionID, RegionName FROM Regions
    </cfquery>
    <cfreturn q>
  </cffunction>

  <!-- ➕ Add Admin -->
  <cffunction name="addAdmin" access="public" returntype="void">
    <cfargument name="fullname" required="true">
    <cfargument name="email" required="true">
    <cfargument name="password" required="true">
    <cfargument name="role" required="true">
    <cfargument name="regionID" required="false" default="">

    <cfquery datasource="laundryservice">
      INSERT INTO Admins (FullName, Email, PasswordHash, Role, RegionID, CreatedAt)
      VALUES (
        <cfqueryparam value="#fullname#">,
        <cfqueryparam value="#email#">,
        <cfqueryparam value="#hash(password, 'SHA-256')#">,
        <cfqueryparam value="#role#">,
        <cfqueryparam value="#regionID#">,
        NOW()
      )
    </cfquery>
  </cffunction>

  <!-- 👥 Get All Agents -->
  <cffunction name="getAgents" access="public" returntype="query">
    <cfquery name="q" datasource="laundryservice">
      SELECT AgentID, FullName, Email, Phone, Status, CreatedAt FROM Agents
    </cfquery>
    <cfreturn q>
  </cffunction>

  <!-- ⛔ Disable Agent -->
  <cffunction name="disableAgent" access="public" returntype="void">
    <cfargument name="agentID" required="true">
    <cfquery datasource="laundryservice">
      UPDATE Agents SET Status = 'Inactive'
      WHERE AgentID = <cfqueryparam value="#agentID#">
    </cfquery>
  </cffunction>

  <!-- 🏪 Stores -->
  <cffunction name="getStores" access="public" returntype="query">
    <cfquery name="q" datasource="laundryservice">
      SELECT StoreID, StoreName, RegionID, Address FROM Stores
    </cfquery>
    <cfreturn q>
  </cffunction>

  <!-- 📈 Order Reports -->
  <cffunction name="getOrderReports" access="public" returntype="query">
    <cfargument name="regionID" required="false">
    <cfargument name="storeID" required="false">
    <cfargument name="status" required="false">

    <cfquery name="q" datasource="laundryservice">
  SELECT o.OrderID, o.Status, o.TotalItems, o.TotalEstimatedCost,
         s.StoreName, r.RegionName, u.FullName, o.CreatedAt
  FROM Orders o
  JOIN Users u ON o.UserID = u.UserID
  JOIN Stores s ON o.StoreID = s.StoreID
  JOIN Regions r ON s.RegionID = r.RegionID
  WHERE 1=1
  <cfif structKeyExists(arguments, "regionID") AND len(trim(arguments.regionID))>
    AND r.RegionID = <cfqueryparam value="#arguments.regionID#" cfsqltype="cf_sql_integer">
  </cfif>
  <cfif structKeyExists(arguments, "storeID") AND len(trim(arguments.storeID))>
    AND s.StoreID = <cfqueryparam value="#arguments.storeID#" cfsqltype="cf_sql_integer">
  </cfif>
  <cfif structKeyExists(arguments, "status") AND len(trim(arguments.status))>
    AND o.Status = <cfqueryparam value="#arguments.status#">
  </cfif>
  ORDER BY o.CreatedAt DESC
</cfquery>


    <cfreturn q>
  </cffunction>

  <!-- 📍 Requests by Region -->
  <cffunction name="getRequestsByRegion" access="public" returntype="query">
    <cfquery name="q" datasource="laundryservice">
      SELECT r.RegionName, COUNT(*) AS OrderCount
      FROM Orders o
      JOIN Stores s ON o.StoreID = s.StoreID
      JOIN Regions r ON s.RegionID = r.RegionID
      GROUP BY r.RegionName
    </cfquery>
    <cfreturn q>
  </cffunction>

  <!-- 📊 Store Performance -->
  <cffunction name="getStorePerformance" access="public" returntype="query">
    <cfquery name="q" datasource="laundryservice">
      SELECT s.StoreName, COUNT(*) AS TotalOrders
      FROM Orders o
      JOIN Stores s ON o.StoreID = s.StoreID
      GROUP BY s.StoreName
    </cfquery>
    <cfreturn q>
  </cffunction>

  <!-- 👤 Agent Performance -->
  <cffunction name="getAgentPerformance" access="public" returntype="query">
    <cfquery name="q" datasource="laundryservice">
      SELECT a.FullName, COUNT(*) AS DeliveredOrders
      FROM Orders o
      JOIN Agents a ON o.AgentID = a.AgentID
      WHERE o.Status = 'Delivered'
      GROUP BY a.FullName
    </cfquery>
    <cfreturn q>
  </cffunction>

  <cffunction name="getAdminByID" access="public" returntype="query">
  <cfargument name="adminID" required="true">

  <cfquery name="q" datasource="laundryservice">
    SELECT AdminID, FullName, Email, Role, RegionID
    FROM Admins
    WHERE AdminID = <cfqueryparam value="#arguments.adminID#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfreturn q>
</cffunction>


</cfcomponent>
