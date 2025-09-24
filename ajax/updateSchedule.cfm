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
  SET DeliveryDate = <cfqueryparam value="#form.newDate#" cfsqltype="cf_sql_date">,
      DeliveryTime = <cfqueryparam value="#form.newTime#" cfsqltype="cf_sql_time">
  WHERE OrderID = <cfqueryparam value="#form.orderid#">
</cfquery>

<cfoutput>Updated</cfoutput>
