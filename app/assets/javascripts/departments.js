document.addEventListener("turbolinks:load", function() {
  "use strict";

  $('#departments-datatable').dataTable({
    "processing": true,
    "serverSide": true,
    "ajax": $('#users-datatable').data('source'),
    "pagingType": "full_numbers",
    "columns": [
      {"data": "id"},
      {"data": "name"},
      {"data": "managed_by_department"},
      {"data": "admin_action", bSortable: false}
    ],
    stateSave: true,
    stateSaveCallback: function(settings, data) {
        localStorage.setItem('DataTables_departments-datatable', JSON.stringify(data));
      },
    stateLoadCallback: function(settings) {
      return JSON.parse(localStorage.getItem('DataTables_departments-datatable'));
      }
  });
})

document.addEventListener("turbolinks:before-cache", function() {
  if($("#departments-datatable_wrapper").length == 1) {
    $('#departments-datatable').DataTable().destroy();
  }
})
