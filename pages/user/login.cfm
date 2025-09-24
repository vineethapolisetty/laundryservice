<cfset loginError = "" />

<cfif structKeyExists(form, "email") AND structKeyExists(form, "password")>
  <cftry>
    <cfset userService = createObject("component", "components.UserService") />
    <cfset result = userService.loginUser(email=trim(form.email), password=trim(form.password)) />

    <cfif isQuery(result) AND result.recordCount EQ 1>
      <!-- ✅ Set sessions (keep your existing keys) -->
      <cfset session.userID   = result.UserID />
      <cfset session.userName = result.FullName />
      <!-- 🔁 Mirror to match Application.cfc guard -->
      <cfset session.userid = session.userID />

      <!-- Redirect to user dashboard -->
      <cflocation url="/laundryservice/index.cfm?fuse=dashboard" addtoken="false" />
    <cfelse>
      <cfset loginError = "Invalid email or password." />
    </cfif>

    <cfcatch type="any">
      <cfset loginError = "Unexpected error: #encodeForHTML(cfcatch.message)#" />
    </cfcatch>
  </cftry>
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Login - LaundryLink</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <!-- Tailwind (UI only) -->
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <style>
    .brand-gradient { background-image: linear-gradient(135deg, rgba(91,94,225,.9), rgba(59,130,246,.85)); }
    .dark-mode .card, .dark-mode .social-btn, .dark-mode .hint { background-color:#1f2937; color:#e5e7eb; }
    .dark-mode .input { background-color:#111827; color:#e5e7eb; border-color:#374151; }
  </style>
</head>
<body class="min-h-screen bg-gray-50 text-gray-800">

  <div class="flex min-h-screen">
    <!-- Left: Visual -->
    <div class="hidden lg:flex w-1/2 relative items-center justify-center overflow-hidden">
      <img src="/laundryservice/images/fabric.jpg" alt="Laundry" class="absolute inset-0 w-full h-full object-cover">
      <div class="absolute inset-0 brand-gradient"></div>
      <div class="relative z-10 text-white px-12">
        <div class="flex items-center space-x-3 mb-6">
          <span class="inline-flex items-center justify-center h-10 w-10 rounded-xl bg-white bg-opacity-20">🧺</span>
          <h1 class="text-3xl font-bold">LaundryLink</h1>
        </div>
        <p class="text-lg opacity-95">Fast, reliable laundry pick-up & delivery. Track your orders in real time.</p>
      </div>
    </div>

    <!-- Right: Form -->
    <div class="w-full lg:w-1/2 flex items-center justify-center p-6 sm:p-10">
      <div class="card w-full max-w-md bg-white rounded-2xl shadow-xl p-8">
        <div class="mb-8">
          <h2 class="text-2xl font-bold">Welcome to <span class="text-indigo-600">LaundryLink</span></h2>
          <p class="text-sm text-gray-500 mt-1">Sign in or create an account to get started.</p>
        </div>

        <!-- Error -->
        <cfif len(loginError)>
          <div class="mb-4 rounded-lg border border-red-200 bg-red-50 text-red-700 px-4 py-3 text-sm">
            <cfoutput>#loginError#</cfoutput>
          </div>
        </cfif>

        <!-- Login form -->
        <form method="post" action="/laundryservice/index.cfm?fuse=login" autocomplete="off" class="space-y-4">
          <div>
            <label class="text-sm font-medium text-gray-700">Email</label>
            <div class="mt-1 relative">
              <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">📧</span>
              <input class="input w-full pl-10 pr-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent transition"
                     type="email" name="email" placeholder="you@example.com" required />
            </div>
          </div>

          <div>
            <div class="flex items-center justify-between">
              <label class="text-sm font-medium text-gray-700">Password</label>
              <a href="forgot_password.cfm" class="text-xs text-indigo-600 hover:text-indigo-700">Forgot password?</a>
            </div>
            <div class="mt-1 relative">
              <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">🔒</span>
              <input class="input w-full pl-10 pr-10 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent transition"
                     type="password" name="password" placeholder="••••••••" required />
            </div>
          </div>

          <button type="submit"
                  class="w-full inline-flex items-center justify-center rounded-lg bg-indigo-600 text-white font-semibold py-2.5 hover:bg-indigo-700 focus:ring-4 focus:ring-indigo-300 transition">
            Login
          </button>
        </form>

        <!-- Divider -->
        <div class="flex items-center my-6">
          <div class="flex-grow h-px bg-gray-200"></div>
          <span class="px-3 text-xs text-gray-400 uppercase tracking-wider">or</span>
          <div class="flex-grow h-px bg-gray-200"></div>
        </div>

        <!-- Social login -->
<div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
  <button type="button" onclick="location.href='/laundryservice/index.cfm?fuse=index&fuse=index&fuse=email_login'"
    class="social-btn w-full rounded-lg border border-gray-200 py-2.5 text-sm hover:bg-gray-50">Email Link</button>
  
    <button type="button" onclick="location.href='oauth_apple.cfm'"
    class="social-btn w-full rounded-lg border border-gray-200 py-2.5 text-sm hover:bg-gray-50">Apple</button>
  
    <button type="button" onclick="location.href='oauth_facebook.cfm'"
    class="social-btn w-full rounded-lg border border-gray-200 py-2.5 text-sm hover:bg-gray-50">Facebook</button>
</div>



        <!-- Sign up -->
        <p class="hint mt-6 text-sm text-gray-500">
          New to LaundryLink?
          <a href="/laundryservice/index.cfm?fuse=signup" class="text-indigo-600 hover:text-indigo-700 font-medium">Create an account</a>
        </p>

        <!-- Footer links -->
        <div class="mt-6 flex flex-wrap items-center justify-between text-xs text-gray-400">
          <p>By signing in, you agree to our <a href="#" class="underline">Terms</a> & <a href="#" class="underline">Privacy</a>.</p>
          <div class="flex items-center gap-3 mt-2 sm:mt-0">
            <button type="button" onclick="document.body.classList.toggle('dark-mode')" class="px-2 py-1 rounded border border-gray-200 hover:bg-gray-50">🌓 Dark</button>
            <a href="/laundryservice/" class="hover:underline">Back to site</a>
            <a href="/laundryservice/index.cfm?fuse=agent_dashboard" class="hover:underline">Agent</a>
            <a href="/laundryservice/index.cfm?fuse=admin_dashboard" class="hover:underline">Admin</a>
          </div>
        </div>
      </div>
    </div>
  </div>

</body>
</html>
