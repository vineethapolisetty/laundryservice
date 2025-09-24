// Scripts extracted for laundryservice/pages/user/notifications.cfm
async function refreshList(){
    const ul = document.getElementById('notifList');
    try{
      const res = await fetch('notifications.cfm?ajax=1', { headers:{'Accept':'application/json'} });
      const data = await res.json();
      const items = (data && data.items) || [];
      ul.innerHTML = '';
      if(items.length === 0){
        ul.innerHTML = '<li class="empty">No notifications.</li>';
        return;
      }
      items.forEach(n=>{
        const li = document.createElement('li');
        li.className = 'item';
        li.innerHTML = `
  <span class="dot ${n.isRead ? 'read' : ''}"></span>
  <div>
    <div>${escapeHtml(n.message || '')}</div>
    <div class="meta">
      ${n.orderID ? 'Order #' + n.orderID + ' • ' : ''}
      ${escapeHtml(n.sentAt || '')}
    </div>
  </div>`;

        ul.appendChild(li);
      });
    }catch(e){
      ul.innerHTML = '<li class="empty">Couldn’t load notifications.</li>';
      console.error(e);
    }
  }

  function escapeHtml(s){
    return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
  }

  // initial load + refresh every 60s
  refreshList();
  setInterval(refreshList, 60000);