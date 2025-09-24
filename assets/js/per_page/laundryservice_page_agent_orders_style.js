// Scripts extracted for laundryservice/pages/agent/orders.cfm
const searchBox = document.getElementById('searchBox');
  const statusFilter = document.getElementById('statusFilter');
  const clearBtn = document.getElementById('clearFilters');
  const orders = document.querySelectorAll('.orderCard');
  const noResults = document.getElementById('noResults');

  function filterOrders() {
    const search = searchBox.value.toLowerCase();
    const status = statusFilter.value.toLowerCase();

    let visibleCount = 0;

    orders.forEach(card => {
      const orderId = card.dataset.orderid.toLowerCase();
      const customer = card.dataset.customer.toLowerCase();
      const orderStatus = card.dataset.status.toLowerCase();

      const matchesSearch = orderId.includes(search) || customer.includes(search);
      const matchesStatus = !status || orderStatus.includes(status);

      if (matchesSearch && matchesStatus) {
        card.style.display = '';
        visibleCount++;
      } else {
        card.style.display = 'none';
      }
    });

    // 🆕 Toggle no-results message
    noResults.classList.toggle('hidden', visibleCount > 0);
  }

  searchBox.addEventListener('input', filterOrders);
  statusFilter.addEventListener('change', filterOrders);

  // Reset filters
  clearBtn.addEventListener('click', () => {
    searchBox.value = '';
    statusFilter.value = '';
    filterOrders();
  });