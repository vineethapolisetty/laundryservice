// Scripts extracted for laundryservice/pages/agent/agent_orders.cfm
function refreshOrders() {
      fetch("agent_orders.cfm?refresh=1")
        .then(res => res.text())
        .then(html => {
          document.getElementById("ordersTable").innerHTML = html;
        });
    }
    setInterval(refreshOrders, 10000); // refresh every 10 seconds