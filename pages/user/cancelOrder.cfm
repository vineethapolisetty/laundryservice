<cfif NOT structKeyExists(session, "userid")>
  <cflocation url="/laundryservice/index.cfm?fuse=login">
</cfif>

<cfparam name="url.orderId" default="">

<cfif NOT len(trim(url.orderId))>
  <cflocation url="/laundryservice/index.cfm?fuse=orderhistory">
</cfif>

<cfset orderService = createObject("component", "components.OrderService")>

<cftry>
  <!--- Call cancelOrder function --->
  <cfset orderService.cancelOrder(url.orderId, session.userid)>

  <!--- Redirect back to details or history --->
  <cflocation url="/laundryservice/index.cfm?fuse=orderdetails&orderId=#url.orderId#">

  <cfcatch type="any">
    <cfoutput>
      <h2 style="color:red;">Error cancelling order</h2>
      <p>#cfcatch.message#</p>
      <p><a href="/laundryservice/index.cfm?fuse=orderhistory">Back to Orders</a></p>
    </cfoutput>
  </cfcatch>
</cftry>
