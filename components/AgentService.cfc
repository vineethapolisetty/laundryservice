<cfcomponent>

  <!-- Agent Login -->
  <cffunction name="loginAgent" access="public" returntype="query" output="false">
    <cfargument name="email" required="true">
    <cfargument name="password" required="true">
    <cfquery name="qLogin" datasource="laundryservice">
      SELECT AgentID, FullName
      FROM Agents
      WHERE Email = <cfqueryparam value="#arguments.email#">
        AND PasswordHash = <cfqueryparam value="#hash(arguments.password, 'SHA-256')#">
        AND Status = 'Active'
    </cfquery>
    <cfreturn qLogin>
  </cffunction>

  <!-- Orders assigned to agent -->
  <cffunction name="getAssignedOrders" access="public" returntype="query">
  <cfargument name="agentID" type="numeric" required="true">
  <cfquery name="qOrders" datasource="laundryservice">
    SELECT 
      o.OrderID,
      o.Status,
      o.TotalItems,
      o.EstimatedDeliveryDate,
      u.FullName AS CustomerName,
      u.Phone    AS CustomerPhone
    FROM Orders o
    INNER JOIN Users u ON o.UserID = u.UserID
    WHERE o.AgentID = <cfqueryparam value="#arguments.agentID#" cfsqltype="cf_sql_integer">
    ORDER BY o.CreatedAt DESC
  </cfquery>
  <cfreturn qOrders>
</cffunction>


  <!-- Order Detail -->
  <cffunction name="getOrderDetail" access="public" returntype="query">
    <cfargument name="orderID" required="true">
    <cfargument name="agentID" required="true">
    <cfquery name="q" datasource="laundryservice">
      SELECT o.*, c.FullName AS CustomerName, c.Phone AS CustomerPhone
      FROM Orders o
      INNER JOIN Customers c ON o.CustomerID = c.CustomerID
      WHERE o.OrderID = <cfqueryparam value="#arguments.orderID#">
        AND o.AgentID = <cfqueryparam value="#arguments.agentID#">
    </cfquery>
    <cfreturn q>
  </cffunction>

  <!-- Order Items -->
  <cffunction name="getOrderItems" access="public" returntype="query">
    <cfargument name="orderID" required="true">
    <cfquery name="q" datasource="laundryservice">
      SELECT ItemID, ItemName, EstimatedCount, ActualCount
      FROM OrderItems
      WHERE OrderID = <cfqueryparam value="#arguments.orderID#">
    </cfquery>
    <cfreturn q>
  </cffunction>

  <!-- Order Activities -->
  <cffunction name="getOrderActivities" access="public" returntype="query">
    <cfargument name="orderID" required="true">
    <cfquery name="q" datasource="laundryservice">
      SELECT Action, ActivityDate
      FROM OrderActivity
      WHERE OrderID = <cfqueryparam value="#arguments.orderID#">
      ORDER BY ActivityDate DESC
    </cfquery>
    <cfreturn q>
  </cffunction>

  <!-- Update Order Status -->
  <cffunction name="updateOrderStatus" access="public">
    <cfargument name="orderID" required="true">
    <cfargument name="newStatus" required="true">
    <cfquery datasource="laundryservice">
      UPDATE Orders
      SET Status = <cfqueryparam value="#arguments.newStatus#">,
          UpdatedAt = NOW()
      WHERE OrderID = <cfqueryparam value="#arguments.orderID#">
    </cfquery>
  </cffunction>

  <!-- Update Item Counts -->
  <cffunction name="updateItemCounts" access="public" returntype="void">
    <cfargument name="formData" type="struct" required="true">
    <cfloop collection="#arguments.formData['count']#" item="itemId">
      <cfquery datasource="laundryservice">
        UPDATE OrderItems
        SET ActualCount = <cfqueryparam value="#arguments.formData['count'][itemId]#" cfsqltype="cf_sql_integer">
        WHERE OrderID = <cfqueryparam value="#arguments.formData['orderid']#" cfsqltype="cf_sql_integer">
          AND ItemID = <cfqueryparam value="#itemId#" cfsqltype="cf_sql_integer">
      </cfquery>
    </cfloop>
  </cffunction>

  <!-- Update Schedule -->
  <cffunction name="updateSchedule" access="public" returntype="void">
    <cfargument name="orderID" required="true">
    <cfargument name="newDate" required="true">
    <cfargument name="newTime" required="true">
    <cfquery datasource="laundryservice">
      UPDATE Orders
      SET DeliveryDate = <cfqueryparam value="#arguments.newDate#" cfsqltype="cf_sql_date">,
          DeliveryTime = <cfqueryparam value="#arguments.newTime#" cfsqltype="cf_sql_time">
      WHERE OrderID = <cfqueryparam value="#arguments.orderID#" cfsqltype="cf_sql_integer">
    </cfquery>
  </cffunction>

  <!-- Mark Delivered -->
  <cffunction name="markOrderDelivered" access="public">
    <cfargument name="orderID" required="true">
    <cfargument name="newDate" required="true">
    <cfquery datasource="laundryservice">
      UPDATE Orders
      SET Status = 'Delivered',
          EstimatedDeliveryDate = <cfqueryparam value="#arguments.newDate#">,
          UpdatedAt = NOW()
      WHERE OrderID = <cfqueryparam value="#arguments.orderID#">
    </cfquery>
  </cffunction>

  <!-- Agent Profile -->
<!-- Agent Profile -->
<cffunction name="getProfile" access="public" returntype="struct">
  <cfargument name="agentID" required="true" type="numeric">

  <cfquery name="qProfile" datasource="laundryservice">
  SELECT 
    a.FullName,
    a.Email,
    a.Phone,
    a.Status,
    a.PhotoUrl,
    r.RegionName,
    s.StoreName
  FROM Agents a
  LEFT JOIN Regions r ON a.RegionID = r.RegionID
  LEFT JOIN Stores s  ON a.StoreID  = s.StoreID
  WHERE a.AgentID = <cfqueryparam value="#arguments.agentID#" cfsqltype="cf_sql_integer">
</cfquery>


  <cfset var result = structNew()>

  <cfif qProfile.recordCount>
    <cfset result = {
      FullName   = qProfile.FullName[1],
      Email      = qProfile.Email[1],
      Phone      = qProfile.Phone[1],
      Status     = qProfile.Status[1],
      RegionName = qProfile.RegionName[1],
      StoreName  = qProfile.StoreName[1],
      PhotoUrl   = qProfile.PhotoUrl[1]
    }>
  <cfelse>
    <!--- Return all keys so page code never breaks --->
    <cfset result = {
      FullName   = "",
      Email      = "",
      Phone      = "",
      Status     = "",
      RegionName = "",
      StoreName  = "",
      PhotoUrl   = ""
    }>
  </cfif>

  <cfreturn result>
</cffunction>

  <!-- Count by Status -->
  <!-- Already exists in your AgentService.cfc -->
<cffunction name="getOrderCountByStatus" access="public" returntype="numeric">
  <cfargument name="status" required="true">
  <cfargument name="agentID" required="true">
  <cfquery name="qCount" datasource="laundryservice">
    SELECT COUNT(*) AS total
    FROM Orders
    WHERE AgentID = <cfqueryparam value="#arguments.agentID#">
      AND Status = <cfqueryparam value="#arguments.status#">
  </cfquery>
  <cfreturn qCount.total>
</cffunction>


</cfcomponent>
