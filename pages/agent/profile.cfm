<cfif NOT structKeyExists(session, "agentid")>
  <cflocation url="/laundryservice/index.cfm?fuse=agent_login">
</cfif>

<cfobject component="components.AgentService" name="agentService">
<cfset profile = agentService.getProfile(session.agentid)>

<!-- Build initials for avatar fallback -->
<cfset initials = "">
<cfset parts = listToArray(trim(profile.FullName), " ")>
<cfloop array="#parts#" index="p">
  <cfset initials &= uCase(left(p,1))>
</cfloop>
<cfif len(initials) GT 2>
  <cfset initials = left(initials,2)>
</cfif>

<!-- Avatar HTML with fallback -->
<cfset avatarHtml = "">
<cfif structKeyExists(profile,"PhotoUrl") AND len(profile.PhotoUrl)>
  <cfset avatarHtml = "<img src='" & encodeForHTML(profile.PhotoUrl) & "' alt='Profile Photo' class='h-full w-full object-cover'>">
<cfelse>
  <cfset avatarHtml = encodeForHTML(initials)>
</cfif>

<!-- Status color -->
<cfset statusClass = "bg-gray-100 text-gray-800">
<cfif profile.Status EQ "Active">
  <cfset statusClass = "bg-green-100 text-green-800">
<cfelseif profile.Status EQ "Inactive">
  <cfset statusClass = "bg-red-100 text-red-800">
<cfelseif profile.Status EQ "On Leave">
  <cfset statusClass = "bg-yellow-100 text-yellow-800">
</cfif>

<!-- Page content -->
<cfset content = "
  <div class='max-w-4xl mx-auto'>

    <!-- Header -->
    <div class='bg-white rounded-2xl shadow p-6 mb-6'>
      <div class='flex items-center gap-4'>
        <div class='h-20 w-20 rounded-full bg-blue-600 flex items-center justify-center text-white text-2xl font-semibold overflow-hidden'>
          #avatarHtml#
        </div>
        <div class='flex-1'>
          <h1 class='text-2xl font-bold leading-tight'>#encodeForHTML(profile.FullName)#</h1>
          <p class='text-gray-500 text-sm'>Field Agent</p>
        </div>
        <span class='px-3 py-1 text-sm rounded-full #statusClass#'>#encodeForHTML(profile.Status)#</span>
      </div>

      <!-- Quick actions -->
      <div class='mt-4 flex flex-wrap gap-3'>
        <a href='tel:#encodeForHTML(profile.Phone)#' class='inline-flex items-center gap-2 px-3 py-2 rounded-lg border border-gray-200 hover:bg-gray-50'>
          <i class='ph ph-phone'></i> Call
        </a>
        <a href='mailto:#encodeForHTML(profile.Email)#' class='inline-flex items-center gap-2 px-3 py-2 rounded-lg border border-gray-200 hover:bg-gray-50'>
          <i class='ph ph-envelope'></i> Email
        </a>
        <a href='/laundryservice/index.cfm?fuse=agent_profile_upload' class='inline-flex items-center gap-2 px-3 py-2 rounded-lg border border-gray-200 hover:bg-gray-50'>
          <i class='ph ph-image'></i> Update Photo
        </a>
      </div>
    </div>

    <!-- Details Grid -->
    <div class='grid md:grid-cols-2 gap-6'>

      <!-- Personal / Contact -->
      <div class='bg-white rounded-2xl shadow p-6'>
        <h2 class='text-lg font-semibold mb-4'>Personal & Contact</h2>
        <dl class='divide-y divide-gray-100'>
          <div class='py-3 flex justify-between'>
            <dt class='text-gray-500'>Full Name</dt>
            <dd class='font-medium'>#encodeForHTML(profile.FullName)#</dd>
          </div>
          <div class='py-3 flex justify-between'>
            <dt class='text-gray-500'>Email</dt>
            <dd class='font-medium'>
              <a href='mailto:#encodeForHTML(profile.Email)#' class='text-blue-600 hover:underline'>#encodeForHTML(profile.Email)#</a>
            </dd>
          </div>
          <div class='py-3 flex justify-between'>
            <dt class='text-gray-500'>Phone</dt>
            <dd class='font-medium'>
              <a href='tel:#encodeForHTML(profile.Phone)#' class='hover:underline'>#encodeForHTML(profile.Phone)#</a>
            </dd>
          </div>
        </dl>
      </div>

      <!-- Assignment -->
      <div class='bg-white rounded-2xl shadow p-6'>
        <h2 class='text-lg font-semibold mb-4'>Assignment</h2>
        <dl class='divide-y divide-gray-100'>
          <div class='py-3 flex justify-between'>
            <dt class='text-gray-500'>Region</dt>
            <dd class='font-medium'>#encodeForHTML(profile.RegionName)#</dd>
          </div>
          <div class='py-3 flex justify-between'>
            <dt class='text-gray-500'>Store</dt>
            <dd class='font-medium'>#encodeForHTML(profile.StoreName)#</dd>
          </div>
          <div class='py-3 flex justify-between'>
            <dt class='text-gray-500'>Role</dt>
            <dd class='font-medium'>Field Agent</dd>
          </div>
        </dl>
      </div>

    </div>

    <!-- Account -->
    <div class='bg-white rounded-2xl shadow p-6 mt-6'>
      <h2 class='text-lg font-semibold mb-4'>Account & Security</h2>
      <div class='flex flex-wrap gap-3'>
        <a href='/laundryservice/index.cfm?fuse=agent_change_password' class='inline-flex items-center gap-2 px-3 py-2 rounded-lg border border-gray-200 hover:bg-gray-50'>
          <i class='ph ph-lock'></i> Change Password
        </a>
        <a href='/laundryservice/index.cfm?fuse=agent_profile_edit' class='inline-flex items-center gap-2 px-3 py-2 rounded-lg border border-gray-200 hover:bg-gray-50'>
          <i class='ph ph-pencil-simple'></i> Edit Profile
        </a>
      </div>
    </div>

  </div>
">

<!-- Render inside shared layout -->
<cfinclude template='../../layouts/agentLayout.cfm'>
