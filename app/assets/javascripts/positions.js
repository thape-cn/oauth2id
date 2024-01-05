document.addEventListener("turbolinks:load", function() {
  "use strict";

  $('#positions-datatable').dataTable({
    "processing": true,
    "serverSide": true,
    "ajax": $('#positions-datatable').data('source'),
    "pagingType": "full_numbers",
    "columns": [
      {"data": "id"},
      {"data": "name"},
      {"data": "functional_category"},
      {"data": "admin_action", bSortable: false}
    ],
    stateSave: true,
    stateSaveCallback: function(settings, data) {
        localStorage.setItem('DataTables_positions-datatable', JSON.stringify(data));
      },
    stateLoadCallback: function(settings) {
      return JSON.parse(localStorage.getItem('DataTables_positions-datatable'));
      }
  });
})

document.addEventListener("turbolinks:before-cache", function() {
  if($("#positions-datatable_wrapper").length == 1) {
    $('#positions-datatable').DataTable().destroy();
  }
})
