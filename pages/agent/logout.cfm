<cfset structDelete(session, "agentid", true)>
<cfset structDelete(session, "agentname", true)>
<cflocation url="/laundryservice/index.cfm?fuse=agent_login">
