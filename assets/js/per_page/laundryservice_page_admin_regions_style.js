// Scripts extracted for laundryservice/pages/admin/regions.cfm
const labels = [<cfoutput query="agentTasks">"#MonthName#"<cfif CurrentRow LT RecordCount>,</cfif></cfoutput>];
const dataValues = [<cfoutput query="agentTasks">#TaskCount#<cfif CurrentRow LT RecordCount>,</cfif></cfoutput>];
new Chart(document.getElementById('agentChart').getContext('2d'), {
    type: 'bar',
    data: {
        labels: labels,
        datasets: [{
            label: 'Tasks Completed',
            data: dataValues,
            backgroundColor: '#0d6efd'
        }]
    }
});