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
      {"data": "email"}
    ]
  });
})
