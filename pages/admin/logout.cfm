<cfset structDelete(session, "adminid", true)>
<cfset structDelete(session, "adminname", true)>
<cfset structDelete(session, "adminrole", true)>
<cflocation url="/laundryservice/index.cfm?fuse=admin_login">
