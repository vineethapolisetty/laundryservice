// Scripts extracted for laundryservice/pages/admin/dashboard.cfm
const regionChart = document.getElementById('regionChart').getContext('2d');
    new Chart(regionChart, {
      type: 'bar',
      data: {
        labels: [<cfoutput query="requestsByRegion">"#RegionName#"<cfif currentRow LT recordCount>,</cfif></cfoutput>],
        datasets: [{
          label: 'Orders',
          data: [<cfoutput query="requestsByRegion">#OrderCount#<cfif currentRow LT recordCount>,</cfif></cfoutput>],
          backgroundColor: 'rgba(54, 162, 235, 0.5)'
        }]
      }
    });

    const storeChart = document.getElementById('storeChart').getContext('2d');
    new Chart(storeChart, {
      type: 'bar',
      data: {
        labels: [<cfoutput query="storePerformance">"#StoreName#"<cfif currentRow LT recordCount>,</cfif></cfoutput>],
        datasets: [{
          label: 'Total Orders',
          data: [<cfoutput query="storePerformance">#TotalOrders#<cfif currentRow LT recordCount>,</cfif></cfoutput>],
          backgroundColor: 'rgba(75, 192, 192, 0.5)'
        }]
      }
    });