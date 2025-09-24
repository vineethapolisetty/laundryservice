// Scripts extracted for laundryservice/pages/agent/tracker.cfm
const container = document.getElementById('trackerBody');
    const btn = document.getElementById('refreshBtn');

    function refreshTracker() {
      fetch('tracker.cfm?ajax=1', { cache: 'no-store' })
        .then(r => r.text())
        .then(html => { container.innerHTML = html; })
        .catch(() => {/* ignore errors */});
    }

    if (btn) btn.addEventListener('click', refreshTracker);
    // Auto refresh every 10s
    setInterval(refreshTracker, 10000);