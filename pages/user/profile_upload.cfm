<cfset this.charset = "UTF-8">
<cfset this.encoding = { url="UTF-8", form="UTF-8", request="UTF-8" }>

<cfif NOT structKeyExists(session, "userID")>
  <cflocation url="/laundryservice/index.cfm?fuse=login" addtoken="false">
</cfif>

<cfset uploadError = "">
<cfset uploadSuccess = false>

<!-- Resolve /laundryservice/uploads/users and ensure folders exist -->
<cfset uploadBase = expandPath("/laundryservice/uploads")>
<cfset uploadDir  = uploadBase & "/users">

<cfif NOT directoryExists(uploadBase)>
  <cfdirectory action="create" directory="#uploadBase#">
</cfif>
<cfif NOT directoryExists(uploadDir)>
  <cfdirectory action="create" directory="#uploadDir#">
</cfif>

<!-- Handle submit -->
<cfif structKeyExists(form, "submitUpload")>
  <cftry>
    <!-- Upload: filefield must match input name below: profilePhoto -->
    <cffile 
      action="upload"
      filefield="profilePhoto"
      destination="#uploadDir#"
      nameconflict="makeunique"
      accept="image/jpeg,image/png,image/gif">

    <!-- Optional: resize to max 600x600 keeping aspect ratio -->
    <cftry>
      <cfset uploadedPath = uploadDir & "/" & cffile.ServerFile>
      <cfimage source="#uploadedPath#" name="imgObj">
      <!-- scale to fit while preserving aspect -->
      <cfset ImageScaleToFit(imgObj, 600, 600)>
      <cfimage action="write" source="#imgObj#" destination="#uploadedPath#" overwrite="true">
      <cfcatch></cfcatch>
    </cftry>

    <!-- Store a web-servable relative path -->
    <cfset relativePath = "/laundryservice/uploads/users/#cffile.ServerFile#">

    <!-- Save to Users.ProfileImage (make sure this column exists) -->
    <cfquery datasource="laundryservice">
      UPDATE Users
      SET ProfileImage = <cfqueryparam cfsqltype="cf_sql_varchar" value="#relativePath#">
      WHERE UserID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.userID#">
    </cfquery>

    <!-- Success: go back to profile -->
    <cflocation url="/laundryservice/index.cfm?fuse=profile" addtoken="false">

    <cfcatch type="any">
      <cfset uploadError = "Upload failed: #encodeForHTML(cfcatch.message)#">
    </cfcatch>
  </cftry>
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Upload Profile Picture</title>
  <style>
    body { font-family: Arial, sans-serif; background:#f4f6f8; margin:0; padding:20px; }
    .container { max-width:420px; margin:40px auto; background:#fff; padding:20px; border-radius:12px; box-shadow:0 2px 8px rgba(0,0,0,0.1); }
    h2 { margin-top:0; color:#5b5ee1; }
    input[type=file] { margin:15px 0; }
    button { background:#5b5ee1; color:#fff; border:none; padding:10px 16px; border-radius:6px; cursor:pointer; }
    .msg { margin:10px 0; font-size:14px; }
    .error { color:#c0392b; }
    a { display:inline-block; margin-top:15px; text-decoration:none; color:#5b5ee1; }
  </style>
</head>
<body>
  <div class="container">
    <h2>Upload Profile Picture</h2>

    <cfif len(uploadError)>
      <div class="msg error"><cfoutput>#uploadError#</cfoutput></div>
    </cfif>

    <!-- IMPORTANT: enctype must be multipart/form-data -->
    <form method="post" enctype="multipart/form-data">
      <input type="file" name="profilePhoto" accept="image/*" required>
      <br>
      <button type="submit" name="submitUpload" value="1">Upload</button>
    </form>

<a href="/laundryservice/index.cfm?fuse=profile">&larr; Back to Profile</a>
  </div>
</body>
</html>
