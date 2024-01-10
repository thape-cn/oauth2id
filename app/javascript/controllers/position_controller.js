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
        {"data": "functional_category"},
        {"data": "admin_action", bSortable: false}
      ],
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_positions-datatable', JSON.stringify(data));
        },
      stateLoadCallback: function() {
        return JSON.parse(localStorage.getItem('DataTables_positions-datatable'));
        }
    });
  }

  disconnect() {
    this.datatable.destroy();
  }
}
