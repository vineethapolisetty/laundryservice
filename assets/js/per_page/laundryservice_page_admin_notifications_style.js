// Scripts extracted for laundryservice/pages/admin/notifications.cfm
function refreshNotifications() {
      $.ajax({
        url: "notifications.cfm?ajax=1",  
        success: function (data) {
          let oldIds = $("#notificationsTable tr[data-id]").map(function () {
            return $(this).data("id");
          }).get();

          $("#notificationsTable").html(data);

          // highlight new rows
          $("#notificationsTable tr[data-id]").each(function () {
            let id = $(this).data("id");
            if (oldIds.indexOf(id) === -1) {
              $(this).addClass("new-highlight");
              setTimeout(() => $(this).removeClass("new-highlight"), 2000);
            }
          });
        }
      });
    }

    // Auto-refresh every 5 seconds
    setInterval(refreshNotifications, 5000);