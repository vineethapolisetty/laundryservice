// Extracted & improved scripts for pages/user/dashboard.cfm
(function () {
  'use strict';

  // Fetch helper for POST (form-encoded)
  function ajaxPost(url, data) {
    return fetch(url, {
      method: 'POST',
      credentials: 'same-origin',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: (typeof data === 'string') ? data : new URLSearchParams(data)
    }).then(function (res) {
      if (!res.ok) throw new Error('Network response was not ok');
      return res.text();
    });
  }

  // Fetch JSON helper (GET)
  function fetchJson(url) {
    return fetch(url, { credentials: 'same-origin' }).then(function (res) {
      if (!res.ok) throw new Error('Network error');
      return res.json();
    });
  }

  // UI references
  var kpiActive = document.getElementById('kpiActive');
  var kpiDelivered = document.getElementById('kpiDelivered');
  var kpiToday = document.getElementById('kpiToday');
  var kpiTotal = document.getElementById('kpiTotal');
  var recentLoader = document.getElementById('recentLoader');
  var recentList = document.getElementById('recentList');
  var toggleBtn = document.getElementById('toggleBtn');
  var sidebar = document.getElementById('sidebar');
  var main = document.getElementById('main');
  var logoutLink = document.getElementById('logoutLink');
  var logoutTop = document.getElementById('logoutTop');

  // Sidebar toggle behavior
var sidebar = document.getElementById('sidebar');
var main = document.getElementById('main');

// NOTE: match the actual ID in your CFML markup
var toggleBtn = document.getElementById('laundryservice_pages_user_dashboard_cfm-auto-evt-1');

function toggleSidebar() {
  if (!sidebar || !main) return;
  if (window.innerWidth <= 900) {
    sidebar.classList.toggle('show');
  } else {
    sidebar.classList.toggle('hidden');
    if (sidebar.classList.contains('hidden')) {
      main.classList.add('full');
    } else {
      main.classList.remove('full');
    }
  }
}

if (toggleBtn) {
  toggleBtn.addEventListener('click', toggleSidebar);
}

// Close sidebar on outside click (mobile)
document.addEventListener('click', function (e) {
  if (window.innerWidth > 900) return;
  var inside = e.target.closest && e.target.closest('#sidebar');
  var isToggle = e.target.closest && e.target.closest('#laundryservice_pages_user_dashboard_cfm-auto-evt-1');
  if (sidebar && sidebar.classList.contains('show') && !inside && !isToggle) {
    sidebar.classList.remove('show');
  }
});


  // Wire top logout button to actual logout link if present
  if (logoutTop && logoutLink) {
    logoutTop.addEventListener('click', function (e) {
      e.preventDefault();
      window.location.href = logoutLink.getAttribute('href');
    });
  }

  // Recent activity loader + metrics updater (uses ?ajax=1)
  var attempts = 0;
  var maxAttempts = 5;
  var retryDelay = 2000; // ms

  function renderRecent(items) {
    recentList.innerHTML = '';
    if (!items || !items.length) {
      recentList.innerHTML = '<li style="color:var(--muted)">No recent activity.</li>';
      return;
    }
    items.forEach(function (it) {
      var li = document.createElement('li');
      li.textContent = it.CreatedAt + ' — Order #' + it.OrderID + ' — ' + it.Status;
      recentList.appendChild(li);
    });
  }

  function updateKPIs(metrics) {
    if (!metrics) return;
    if (kpiActive) kpiActive.textContent = metrics.active || 0;
    if (kpiDelivered) kpiDelivered.textContent = metrics.delivered || 0;
    if (kpiToday) kpiToday.textContent = metrics.today || 0;
    if (kpiTotal) kpiTotal.textContent = metrics.total || 0;
  }

  function loadDashboardData() {
    attempts++;
    // show spinner
    if (recentLoader) recentLoader.style.display = 'flex';
    if (recentList) recentList.style.display = 'none';

    // call same page with ?ajax=1
    fetchJson(window.location.pathname + '?ajax=1')
      .then(function (data) {
        if (recentLoader) recentLoader.style.display = 'none';
        if (recentList) recentList.style.display = '';

        // server returns metrics and recent array
        updateKPIs(data.metrics);
        renderRecent(data.recent);
      })
      .catch(function (err) {
        console.warn('Failed to load dashboard data', err);
        if (attempts < maxAttempts) {
          if (recentLoader) recentLoader.innerHTML = '<span class="spinner"></span><span style="color:#ef4444"> Retrying...</span>';
          setTimeout(loadDashboardData, retryDelay);
        } else {
          if (recentLoader) recentLoader.style.display = 'none';
          if (recentList) {
            recentList.innerHTML = '<li style="color:#ef4444">Failed to load data. Please try again later.</li>';
            recentList.style.display = '';
          }
        }
      });
  }

  // start on DOM ready
  document.addEventListener('DOMContentLoaded', function () {
    // initial load small delay so UI paints
    setTimeout(loadDashboardData, 200);
  });
})();
