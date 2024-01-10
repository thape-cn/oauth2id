import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "datatable" ];
  static values = { source: String }

  connect() {
    this.datatable = $(this.datatableTarget).DataTable({
      "processing": true,
      "serverSide": true,
      "ajax": {
        "url": this.sourceValue
      },
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
      stateLoadCallback: function() {
        return JSON.parse(localStorage.getItem('DataTables_departments-datatable'));
        }
    });
  }

  disconnect() {
    this.datatable.destroy();
  }
}
