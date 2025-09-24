// Scripts extracted for laundryservice/pages/user/orderHistory.cfm
// Client-side filtering and sorting (no backend changes)
  function filterCards(){
    const q = (document.getElementById('searchInput').value || '').toLowerCase().trim();
    const status = (document.getElementById('statusFilter').value || '').toLowerCase();
    const cards = document.querySelectorAll('#cards .order-card');
    cards.forEach(card=>{
      const id = (card.dataset.orderid || '').toLowerCase();
      const drop = (card.dataset.droptype || '').toLowerCase();
      const st = (card.dataset.status || '').toLowerCase();
      const hit = (!q || id.includes(q) || drop.includes(q)) && (!status || st === status);
      card.style.display = hit ? '' : 'none';
    });
  }

  function sortCards(){
    const by = document.getElementById('sortSelect').value;
    const wrap = document.getElementById('cards');
    if(!wrap) return;
    const cards = Array.from(wrap.children);
    cards.sort((a,b)=>{
      const da = a.dataset.date, db = b.dataset.date;
      const aa = parseFloat(a.dataset.amount||0), ab = parseFloat(b.dataset.amount||0);
      if(by === 'dateAsc'){ return (da>db) ? 1 : (da<db ? -1 : 0); }
      if(by === 'dateDesc'){ return (da<db) ? 1 : (da>db ? -1 : 0); }
      if(by === 'amountAsc'){ return aa - ab; }
      if(by === 'amountDesc'){ return ab - aa; }
      return 0;
    });
    cards.forEach(c=>wrap.appendChild(c));
  }

  // Initialize default sort
  document.addEventListener('DOMContentLoaded', ()=>{ sortCards(); });