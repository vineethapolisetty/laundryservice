<cfif structKeyExists(form, "otp") AND form.otp EQ session.otp>
  <cfoutput>
    <h2>✅ Phone Verified!</h2>
    <p>Welcome, user at <strong>#session.phone#</strong>!</p>
    <p><a href="/laundryservice/index.cfm?fuse=signup">Continue to complete registration</a></p>
  </cfoutput>
<cfelse>
  <cfoutput>
    <h2>❌ Invalid OTP</h2>
    <p>Please <a href="login_signup.cfm">try again</a>.</p>
  </cfoutput>
</cfif>
