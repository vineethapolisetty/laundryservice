<cfcomponent output="false">

  <!-- Create new order -->
  <cffunction name="createOrder" access="public" returnType="void">
    <cfargument name="userid" required="true">
    <cfargument name="dropType" required="true">
    <cfargument name="deliveryAddress" required="true">
    <cfargument name="form" required="true">

    <!-- Pricing map -->
    <cfset itemPrices = {
      shirt    = 10,
      pant     = 10,
      towel    = 10,
      delicate = 5,
      bedding  = 20
    }>

    <cfset serviceFee = 5>
    <cfset deliveryFee = (arguments.dropType EQ "DeliveryPickup" ? 20 : 0)>

    <!-- Totals -->
    <cfset totalItems = 0>
    <cfset subtotal   = 0>

    <cfloop collection="#itemPrices#" item="item">
      <cfset qty = val(arguments.form[item])>
      <cfif qty GT 0>
        <cfset totalItems += qty>
        <cfset subtotal   += (qty * itemPrices[item])>
      </cfif>
    </cfloop>

    <cfset grandTotal = subtotal + serviceFee + deliveryFee>

    <!-- Lookup store -->
    <cfquery name="qStore" datasource="laundryservice">
      SELECT StoreID
      FROM Stores
      WHERE StoreID = <cfqueryparam value="#arguments.form.storeID#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!-- Insert into Orders -->
    <cfquery datasource="laundryservice" result="res">
      INSERT INTO Orders (
        UserID, StoreID, DropType, Status,
        EstimatedDeliveryDate, DeliveryAddress,
        TotalItems, TotalEstimatedCost, CreatedAt, AgentID
      )
      VALUES (
        <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#qStore.StoreID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#arguments.dropType#" cfsqltype="cf_sql_varchar">,
        'Pending',
        DATE_ADD(NOW(), INTERVAL 3 DAY),
        <cfqueryparam value="#arguments.deliveryAddress#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#totalItems#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#grandTotal#" cfsqltype="cf_sql_decimal">,
        NOW(),
        NULL
      )
    </cfquery>

    <cfset newOrderID = res.generatedKey>

    <!-- Insert items into OrderItems -->
    <cfloop collection="#itemPrices#" item="item">
      <cfset qty = val(arguments.form[item])>
      <cfif qty GT 0>
        <cfquery datasource="laundryservice">
          INSERT INTO OrderItems (OrderID, ItemType, Quantity, PricePerItem)
          VALUES (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#newOrderID#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#item#">,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#qty#">,
            <cfqueryparam cfsqltype="cf_sql_decimal" value="#itemPrices[item]#">
          )
        </cfquery>
      </cfif>
    </cfloop>
  </cffunction>


  <!-- Single order details -->
  <cffunction name="getOrderDetails" access="public" returnType="query">
    <cfargument name="userID" type="numeric" required="true">
    <cfargument name="orderID" type="numeric" required="true">

    <cfquery name="qOrder" datasource="laundryservice">
      SELECT 
        o.OrderID, o.UserID, o.DropType, o.Status,
        o.TotalItems, o.TotalEstimatedCost,
        o.CreatedAt AS OrderDate, o.EstimatedDeliveryDate, o.DeliveryAddress
      FROM Orders o
      WHERE o.OrderID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.orderID#">
        AND o.UserID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
      LIMIT 1
    </cfquery>
    <cfreturn qOrder>
  </cffunction>


  <!-- Order items -->
  <cffunction name="getOrderItems" access="public" returnType="query">
    <cfargument name="orderID" type="numeric" required="true">
    <cfquery name="qItems" datasource="laundryservice">
      SELECT 
        ItemType AS ItemName,
        Quantity AS Qty,
        PricePerItem AS Rate,
        (Quantity * PricePerItem) AS Amount
      FROM OrderItems
      WHERE OrderID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.orderID#">
    </cfquery>
    <cfreturn qItems>
  </cffunction>


  <!-- Current Orders -->
  <cffunction name="getCurrentOrders" access="public" returnType="query">
    <cfargument name="userid" required="true">
    <cfquery name="q" datasource="laundryservice">
      SELECT OrderID, Status, EstimatedDeliveryDate 
      FROM Orders
      WHERE UserID = <cfqueryparam value="#arguments.userid#"> 
        AND Status != 'Delivered'
    </cfquery>
    <cfreturn q>
  </cffunction>


  <!-- Order History -->
  <cffunction name="getOrderHistory" access="public" returnType="query">
    <cfargument name="userid" required="true">

    <cfquery name="qHistory" datasource="laundryservice">
      SELECT 
        OrderID,
        Status,
        DropType,
        TotalItems,
        TotalEstimatedCost,
        CreatedAt AS OrderDate
      FROM Orders
      WHERE UserID = <cfqueryparam value="#arguments.userid#">
      ORDER BY CreatedAt DESC
    </cfquery>

    <cfreturn qHistory>
  </cffunction>


  <!-- Get User Orders -->
  <cffunction name="getUserOrders" access="public" returntype="query">
    <cfargument name="userID" required="true">
    <cfargument name="type" required="true"> <!-- active / past -->

    <cfquery name="q" datasource="laundryservice">
      SELECT OrderID, Status, EstimatedDeliveryDate, TotalItems
      FROM Orders
      WHERE UserID = <cfqueryparam value="#arguments.userID#">
      <cfif arguments.type EQ "active">
        AND Status IN ('Pending', 'Accepted', 'InProgress')
      <cfelse>
        AND Status IN ('Delivered', 'Cancelled')
      </cfif>
      ORDER BY CreatedAt DESC
    </cfquery>

    <cfreturn q>
  </cffunction>

  <cffunction name="deleteOrder" access="public" returnType="void">
  <cfargument name="orderID" type="numeric" required="true">
  <cfargument name="userID" type="numeric" required="true">

  <!-- Delete child records first (FK safety) -->
  <cfquery datasource="laundryservice">
    DELETE FROM OrderItems 
    WHERE OrderID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.orderID#">
  </cfquery>

  <!-- Delete order (only if it belongs to this user) -->
  <cfquery datasource="laundryservice">
    DELETE FROM Orders
    WHERE OrderID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.orderID#">
      AND UserID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
  </cfquery>
</cffunction>

<cffunction name="cancelOrder" access="public" returnType="void">
  <cfargument name="orderID" type="numeric" required="true">
  <cfargument name="userID" type="numeric" required="true">

  <!-- Only allow cancelling if still Pending -->
  <cfquery datasource="laundryservice">
    UPDATE Orders
    SET Status = 'Cancelled'
    WHERE OrderID = <cfqueryparam value="#arguments.orderID#" cfsqltype="cf_sql_integer">
      AND UserID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
      AND Status = 'Pending'
  </cfquery>
</cffunction>



</cfcomponent>
