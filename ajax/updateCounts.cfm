<cfif NOT structKeyExists(session, "agentid")>
  <cfheader statuscode="403" statustext="Forbidden">
  <cfabort>
</cfif>

<cfparam name="form.orderid" default="">
<cfobject component="../components.AgentService" name="agentService">
<cfset order = agentService.getOrderDetail(form.orderid, session.agentid)>
<cfif order.recordCount EQ 0>
  <cfoutput>Invalid</cfoutput>
  <cfabort>
</cfif>

<cfloop collection="#form.count#" item="itemID">
  <cfquery datasource="laundryservice">
    UPDATE OrderItems
    SET ActualCount = <cfqueryparam value="#form.count[itemID]#">
    WHERE OrderID = <cfqueryparam value="#form.orderid#">
      AND ItemID = <cfqueryparam value="#itemID#">
  </cfquery>
</cfloop>

<cfoutput>OK</cfoutput>
