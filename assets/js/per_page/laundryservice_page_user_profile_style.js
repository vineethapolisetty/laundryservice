// Scripts extracted for laundryservice/pages/user/profile.cfm
// demo only — wire to your endpoint later
  function savePrefs(){
    const prefs = {
      orderUpdates: document.getElementById('togOrderUpdates').checked,
      promos: document.getElementById('togPromos').checked,
      agent: document.getElementById('togAgent').checked
    };
    alert('Preferences updated:\\n' + JSON.stringify(prefs, null, 2));
  }