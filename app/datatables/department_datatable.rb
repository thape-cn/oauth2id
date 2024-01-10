class DepartmentDatatable < ApplicationDatatable
  extend Forwardable

  def_delegator :@view, :edit_department_path

  def initialize(params, opts = {})
    @departments = opts[:departments]
    super
  end

  def view_columns
    @view_columns ||= {
      id: { source: 'Department.id', cond: :eq, searchable: true, orderable: true },
      name: { source: 'Department.name', cond: :like, searchable: true, orderable: true },
      managed_by_department: { source: 'Department.name', cond: :like, searchable: true, orderable: true },
      admin_action: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    records.map do |record|
      { id: record.id,
        name: record.name,
        managed_by_department: record.managed_by_department&.name,
        admin_action: link_to(fa_icon('edit'), edit_department_path(record), remote: true) }
    end
  end

  def get_raw_records
    @departments
  end
end
