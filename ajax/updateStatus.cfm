<cfif NOT structKeyExists(session, "agentid")>
  <cfheader statuscode="403">
  <cfabort>
</cfif>

<cfobject component="../components.AgentService" name="agentService">
<cfset order = agentService.getOrderDetail(form.orderid, session.agentid)>
<cfif order.recordCount EQ 0>
  <cfoutput>Invalid</cfoutput>
  <cfabort>
</cfif>

<cfquery datasource="laundryservice">
  UPDATE Orders
  SET Status = <cfqueryparam value="#form.status#">
  WHERE OrderID = <cfqueryparam value="#form.orderid#">
</cfquery>

<!-- Log activity -->
<cfquery datasource="laundryservice">
  INSERT INTO OrderActivity (OrderID, Action, ActivityDate)
  VALUES (
    <cfqueryparam value="#form.orderid#">,
    <cfqueryparam value="Status updated to #form.status#">,
    <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
  )
</cfquery>

<cfoutput>Done</cfoutput>
