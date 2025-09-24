<!--- /pages/user/profile.cfm --->
<cfprocessingdirective pageencoding="utf-8">
<cfcontent type="text/html; charset=UTF-8">

<cfif NOT structKeyExists(session, "userid")>
  <cflocation url="/laundryservice/index.cfm?fuse=login" addtoken="false">
</cfif>

<!-- Load profile -->
<cfobject component="components.UserService" name="userService">
<cfset profileQ = userService.getProfile(session.userid)>
<cfset hasProfile = isQuery(profileQ) AND profileQ.recordCount GT 0>

<!-- Safe column presence -->
<cfset cols = hasProfile ? profileQ.columnList : "">
<cfset hasName   = hasProfile AND listFindNoCase(cols,"FullName")>
<cfset hasEmail  = hasProfile AND listFindNoCase(cols,"Email")>
<cfset hasPhone  = hasProfile AND listFindNoCase(cols,"Phone")>
<cfset hasAddr   = hasProfile AND listFindNoCase(cols,"Address")>
<cfset hasAvatar = hasProfile AND listFindNoCase(cols,"ProfileImage")>

<!-- Safe values -->
<cfset _name   = hasName   ? toString(profileQ["FullName"][1])    : "User">
<cfset _email  = hasEmail  ? toString(profileQ["Email"][1])       : "">
<cfset _phone  = hasPhone  ? toString(profileQ["Phone"][1])       : "">
<cfset _addr   = hasAddr   ? toString(profileQ["Address"][1])     : "">
<cfset _avatar = hasAvatar ? toString(profileQ["ProfileImage"][1]): "">

<!-- Build initials as fallback -->
<cfset initials = "">
<cfif len(trim(_name))>
  <cfset parts = listToArray(_name, " ")>
  <cfloop array="#parts#" index="p">
    <cfif len(initials) LT 2><cfset initials &= uCase(left(p,1))></cfif>
  </cfloop>
<cfelseif len(trim(_email))>
  <cfset initials = uCase(left(_email,1))>
<cfelse>
  <cfset initials = "U">
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Profile & Settings</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    :root{
      --bg:#f4f6fb; --card:#ffffff; --text:#1f2937; --muted:#6b7280; --line:#e5e7eb;
      --brand:#5b5ee1; --danger:#ef4444; --ok:#22c55e; --shadow:0 8px 24px rgba(16,24,40,.08);
      --radius:16px;
    }
    *{ box-sizing:border-box }
    body{
      margin:0; background:var(--bg); color:var(--text);
      font-family:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Arial;
      padding-bottom:80px; -webkit-tap-highlight-color: transparent;
    }
    .header{
      position:sticky; top:0; z-index:10; background:#fff; padding:14px 16px;
      display:flex; align-items:center; justify-content:space-between; border-bottom:1px solid var(--line);
    }
    .header h2{ margin:0; font-size:20px; font-weight:800; }
    .header .icons{ display:flex; gap:12px; color:var(--muted); }
    .container{ max-width:780px; margin:0 auto; padding:16px; }
    .card{
      background:var(--card); border:1px solid var(--line); border-radius:var(--radius);
      box-shadow:var(--shadow); padding:16px; margin-bottom:16px;
    }
    .profile-head{ display:flex; align-items:center; gap:14px; }
    .avatar{
      width:72px; height:72px; border-radius:50%; display:inline-flex; align-items:center; justify-content:center;
      background:#eef2ff; color:#4f46e5; font-weight:800; font-size:22px; overflow:hidden;
      border:1px solid #e0e7ff;
    }
    .avatar img{ width:100%; height:100%; object-fit:cover; display:block; }
    .facts h3{ margin:0 0 4px; font-size:18px; }
    .muted{ color:var(--muted); font-size:13px; }
    .actions{ display:flex; gap:10px; flex-wrap:wrap; margin-top:12px; }
    .btn{
      display:inline-flex; align-items:center; justify-content:center; gap:8px;
      padding:10px 12px; border-radius:12px; border:1px solid transparent;
      text-decoration:none; font-weight:800; font-size:13px; cursor:pointer;
    }
    .btn-primary{ background:var(--brand); color:#fff; }
    .btn-secondary{ background:#fff; color:var(--brand); border-color:var(--brand); }
    .btn-danger{ background:#fff5f5; color:var(--danger); border:1px solid #ffe3e3; }
    .btn-block{ width:100%; }
    .toggle-row{ display:flex; align-items:center; justify-content:space-between; gap:12px; padding:8px 0; }
    .switch{ position:relative; width:44px; height:24px; }
    .switch input{ opacity:0; width:0; height:0; }
    .slider{ position:absolute; inset:0; background:#c7c9d6; border-radius:999px; transition:all .25s; }
    .slider:before{ content:""; position:absolute; width:18px; height:18px; left:3px; top:3px; background:#fff; border-radius:50%; transition:all .25s; box-shadow:0 1px 3px rgba(0,0,0,.15); }
    .switch input:checked + .slider{ background:var(--brand); }
    .switch input:checked + .slider:before{ transform:translateX(20px); }
    .pm{ border:1px solid var(--line); border-radius:12px; padding:12px; margin-top:10px; }
    .pm .row{ display:flex; align-items:center; justify-content:space-between; gap:8px; }
    .footer-nav{
      position:fixed; left:0; right:0; bottom:0; height:64px; background:#fff; border-top:1px solid var(--line);
      display:flex; align-items:center; justify-content:space-around; z-index:20;
    }
    .footer-nav a{ text-decoration:none; color:var(--text); font-size:12px; display:flex; flex-direction:column; align-items:center; gap:4px; }
    .footer-nav a.active{ color:var(--brand); }

  

  </style>
</head>
<body>

<div class="header">
  <h2>Profile &amp; Settings</h2>
  <div class="icons">
    <a href="/laundryservice/index.cfm?fuse=supportchat" aria-label="Support" title="Support" style="color:inherit"><i class="fa-regular fa-message"></i></a>
    <a href="/laundryservice/index.cfm?fuse=notifications" aria-label="Notifications" title="Notifications" style="color:inherit"><i class="fa-regular fa-bell"></i></a>
  </div>
</div>

<div class="container">

  <div class="card">
    <div class="profile-head">
      <div class="avatar">
        <cfif len(trim(_avatar))>
          <!-- cache-bust so the new photo shows immediately after upload -->
          <cfset imgSrc = _avatar & "?v=" & createUUID()>
          <cfoutput><img src="#encodeForHTMLAttribute(imgSrc)#" alt="Profile photo"></cfoutput>
        <cfelse>
          <cfoutput>#encodeForHTML(initials)#</cfoutput>
        </cfif>
      </div>
      <div class="facts">
        <cfoutput>
          <h3>#encodeForHTML(_name)#</h3>
          <cfif len(trim(_email))><div class="muted"><i class="fa-regular fa-envelope"></i> #encodeForHTML(_email)#</div></cfif>
          <cfif len(trim(_phone))><div class="muted"><i class="fa-solid fa-phone"></i> #encodeForHTML(_phone)#</div></cfif>
          <cfif len(trim(_addr))><div class="muted"><i class="fa-solid fa-location-dot"></i> #encodeForHTML(_addr)#</div></cfif>
        </cfoutput>
      </div>
    </div>

    <div class="actions">
      <a class="btn btn-secondary" href="/laundryservice/index.cfm?fuse=profile_edit"><i class="fa-regular fa-user"></i> Edit Profile</a>
      <a class="btn btn-secondary" href="/laundryservice/index.cfm?fuse=profile_upload"><i class="fa-regular fa-image"></i> Change Photo</a>
      <a class="btn btn-primary" href="/laundryservice/index.cfm?fuse=supportchat"><i class="fa-solid fa-headset"></i> Contact Support</a>
    </div>
  </div>

  <div class="card">
    <h4 style="margin:0 0 6px;">Account Settings</h4>

    <div class="toggle-row">
      <div>
        <div><strong>Order Updates</strong></div>
        <div class="muted">Receive notifications about your laundry orders</div>
      </div>
      <label class="switch">
        <input id="togOrderUpdates" type="checkbox" checked>
        <span class="slider"></span>
      </label>
    </div>

    <div class="toggle-row">
      <div>
        <div><strong>Promotions &amp; Offers</strong></div>
        <div class="muted">Get updates on discounts and offers</div>
      </div>
      <label class="switch">
        <input id="togPromos" type="checkbox">
        <span class="slider"></span>
      </label>
    </div>

    <div class="toggle-row">
      <div>
        <div><strong>Agent Messages</strong></div>
        <div class="muted">Allow agents to message you about your orders</div>
      </div>
      <label class="switch">
        <input id="togAgent" type="checkbox" checked>
        <span class="slider"></span>
      </label>
    </div>

    <div class="actions">
      <button class="btn btn-primary btn-block" onclick="savePrefs()">Save Preferences</button>
    </div>
  </div>

  <div class="card">
    <h4 style="margin:0 0 6px;">Payment Methods</h4>

    <!-- static examples; replace with your real list later -->
    <div class="pm">
      <div class="row">
        <strong><i class="fa-regular fa-credit-card"></i> Visa &bull;&bull;&bull;&bull; 4242</strong>
        <span>(Default)</span>
      </div>
      <small>Expires 12/26</small>
      <div class="actions" style="margin-top:10px;">
        <button class="btn btn-secondary"><i class="fa-regular fa-pen-to-square"></i> Edit</button>
        <button class="btn btn-danger"><i class="fa-regular fa-trash-can"></i> Remove</button>
      </div>
    </div>

    <div class="pm">
      <div class="row">
        <strong><i class="fa-regular fa-credit-card"></i> Mastercard &bull;&bull;&bull;&bull; 7890</strong>
        <span>&nbsp;</span>
      </div>
      <small>Expires 08/25</small>
      <div class="actions" style="margin-top:10px;">
        <button class="btn btn-secondary"><i class="fa-regular fa-pen-to-square"></i> Edit</button>
        <button class="btn btn-danger"><i class="fa-regular fa-trash-can"></i> Remove</button>
      </div>
    </div>

    <div class="actions" style="margin-top:10px;">
      <a class="btn btn-primary btn-block" href="/laundryservice/index.cfm?fuse=payment_add"><i class="fa-solid fa-plus"></i> Add New Payment Method</a>
    </div>
  </div>

  <div class="card">
    <h4 style="margin:0 0 6px;">Security &amp; Privacy</h4>
    <div class="actions">
      <a class="btn btn-secondary" href="/laundryservice/index.cfm?fuse=change_password"><i class="fa-solid fa-key"></i> Change Password</a>
      <a class="btn btn-secondary" href="privacy.cfm"><i class="fa-regular fa-file-lines"></i> Privacy Policy</a>
    </div>
  </div>
<div class="actions">
  <button type="button" class="btn btn-danger btn-block"
          onclick="window.location.href='/laundryservice/index.cfm?fuse=logout'">
    <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
  </button>
</div>


<nav class="footer-nav" aria-label="Bottom navigation">
  <a href="/laundryservice/index.cfm?fuse=dashboard"><i class="fa-solid fa-house"></i><span>Home</span></a>
  <a href="/laundryservice/index.cfm?fuse=orderhistory"><i class="fa-solid fa-clipboard-list"></i><span>History</span></a>
  <a href="/laundryservice/index.cfm?fuse=profile" class="active"><i class="fa-solid fa-user"></i><span>Profile</span></a>
</nav>

<script>
  // demo only — wire to your endpoint later
  function savePrefs(){
    const prefs = {
      orderUpdates: document.getElementById('togOrderUpdates').checked,
      promos: document.getElementById('togPromos').checked,
      agent: document.getElementById('togAgent').checked
    };
    alert('Preferences updated:\\n' + JSON.stringify(prefs, null, 2));
  }
</script>
</body>
</html>
