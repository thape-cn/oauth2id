document.addEventListener("turbolinks:load", function() {
  "use strict";

  $('#users-datatable').dataTable({
    "processing": true,
    "serverSide": true,
    "ajax": $('#users-datatable').data('source'),
    "pagingType": "full_numbers",
    "columns": [
      {"data": "id"},
      {"data": "username"},
      {"data": "chinese_name"},
      {"data": "clerk_code"},
      {"data": "email"},
      {"data": "admin_action", bSortable: false}
    ],
    stateSave: true,
    stateSaveCallback: function(settings, data) {
        localStorage.setItem('DataTables_users-datatable', JSON.stringify(data));
      },
    stateLoadCallback: function(settings) {
      return JSON.parse(localStorage.getItem('DataTables_users-datatable'));
      }
  });

  $('#tree-department').tree({
      closedIcon: $('<i class="icon fa fa-arrow-circle-right"></i>'),
      openedIcon: $('<i class="icon fa fa-arrow-circle-down"></i>')
  }).on(
    'tree.click',
    function(event) {
      var node = event.node;
      if(node.id != undefined) {
        if($("#users-datatable_wrapper").length == 1) {
          $('#users-datatable').DataTable().destroy();
        }
        $('#users-datatable').dataTable({
          "processing": true,
          "serverSide": true,
          "ajax": $('#users-datatable').data('source') + "?dept_id=" + node.id,
          "pagingType": "full_numbers",
          "columns": [
            {"data": "id"},
            {"data": "username"},
            {"data": "chinese_name"},
            {"data": "clerk_code"},
            {"data": "email"},
            {"data": "admin_action", bSortable: false}
          ],
          stateSave: true,
          stateSaveCallback: function(settings, data) {
              localStorage.setItem('DataTables_users-datatable', JSON.stringify(data));
            },
          stateLoadCallback: function(settings) {
            return JSON.parse(localStorage.getItem('DataTables_users-datatable'));
            }
        });
      }
    }
  );
})

document.addEventListener("turbolinks:before-cache", function() {
  if($("#users-datatable_wrapper").length == 1) {
    $('#users-datatable').DataTable().destroy();
  }
})
