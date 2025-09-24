// Scripts extracted for laundryservice/pages/agent/orderDetails.cfm
$('#countForm').on('submit', function(e) {
      e.preventDefault();
      $.post('../../ajax/updateCounts.cfm', $(this).serialize())
        .done(function() { alert('Counts updated!'); })
        .fail(function() { alert('Failed to update counts'); });
    });

    $('#scheduleForm').on('submit', function(e) {
      e.preventDefault();
      $.post('../../ajax/updateSchedule.cfm', $(this).serialize())
        .done(function() { alert('Schedule updated!'); })
        .fail(function() { alert('Failed to update schedule'); });
    });

    function updateStatus(status) {
      $.post('../../ajax/updateStatus.cfm', {
        orderid: '<cfoutput>#encodeForJavaScript(order.OrderID)#</cfoutput>',
        status: status
      })
      .done(function() {
        alert('Order marked as ' + status);
        location.reload();
      })
      .fail(function() {
        alert('Failed to update status');
      });
    }