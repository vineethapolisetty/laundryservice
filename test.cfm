<cftry>
  <cfobject component="components.UserService" name="testService">
  <cfoutput> Component loaded successfully.</cfoutput>
  <cfcatch>
    <div style="color:red;">
      <cfoutput>❌ Error: #cfcatch.message#</cfoutput>
    </div>
  </cfcatch>
</cftry>

<cftry>
  <cfobject component="components.OrderService" name="o">
  <cfoutput>✅ OrderService loaded successfully.</cfoutput>
  <cfcatch>
    <div style="color:red;">
      <cfoutput>❌ Error: #cfcatch.message#</cfoutput>
    </div>
  </cfcatch>
</cftry>
