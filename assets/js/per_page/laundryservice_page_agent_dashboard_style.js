// Scripts extracted for laundryservice/pages/agent/dashboard.cfm
const ctx = document.getElementById('ordersChart').getContext('2d');
  const chartData = {
    labels: ['North','East','West','South'],
    datasets: [{
      label: 'Orders',
      data: [#regionCounts['North']#,#regionCounts['East']#,#regionCounts['West']#,#regionCounts['South']#],
      backgroundColor: ['#3b82f6','#6366f1','#10b981','#f59e0b']
    }]
  };
  const ordersChart = new Chart(ctx,{ type:'bar', data: chartData,
    options:{ responsive:true, plugins:{legend:{position:'bottom'}}, scales:{y:{beginAtZero:true,ticks:{precision:0}}} }
  });

  const $pending   = document.getElementById('tilePending');
  const $today     = document.getElementById('tileToday');
  const $delivered = document.getElementById('tileDelivered');
  const $total     = document.getElementById('tileTotal');
  const $acts      = document.getElementById('activitiesList');
  const $btn       = document.getElementById('dashRefresh');

  function renderActivities(list){
    $acts.innerHTML = '';
    if(list.length === 0){
      $acts.innerHTML = '<li class="text-gray-500 text-sm">No recent activity.</li>';
      return;
    }
    list.forEach(a => {
      const li = document.createElement('li');
      li.className = 'flex items-center space-x-4';
      li.innerHTML = `
        <i class="ph ph-truck text-indigo-500 text-xl"></i>
        <div>
          <p class="font-medium">${a.OrderID} - ${a.Status}</p>
          <p class="text-sm text-gray-500">Updated: ${a.UpdatedAt}</p>
        </div>`;
      $acts.appendChild(li);
    });
  }

  async function refreshDashboard(){
    try{
      const res = await fetch('dashboard.cfm?ajax=1',{cache:'no-store'});
      const data = await res.json();
      $pending.textContent   = data.pending   ?? 0;
      $today.textContent     = data.today     ?? 0;
      $delivered.textContent = data.delivered ?? 0;
      $total.textContent     = data.total     ?? 0;
      if(data.regionCounts){
        const rc = data.regionCounts;
        ordersChart.data.datasets[0].data = [rc.North||0,rc.East||0,rc.West||0,rc.South||0];
        ordersChart.update();
      }
      renderActivities(data.activities||[]);
    }catch(e){}
  }
  if($btn){ $btn.addEventListener('click',refreshDashboard); }
  setInterval(refreshDashboard,10000);