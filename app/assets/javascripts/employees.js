document.addEventListener("turbolinks:load", function() {
  "use strict";

  if ($("#users-datatable_wrapper").length == 0) {
    $('#users-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "ajax": $('#users-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": [
        {"data": "id"},
        {"data": "username"},
        {"data": "email"}
      ],
      stateSave: true,
      stateSaveCallback: function(settings,data) {
          localStorage.setItem('DataTables_users-datatable', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_users-datatable'));
        }
    });
  }
})
