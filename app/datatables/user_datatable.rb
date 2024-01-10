class UserDatatable < ApplicationDatatable
  extend Forwardable

  def_delegator :@view, :employee_path
  def_delegator :@view, :edit_employee_path

  def initialize(params, opts = {})
    @users = opts[:users]
    super
  end

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id: { source: 'User.id', cond: :eq, searchable: true, orderable: true },
      username: { source: 'User.username', cond: :like, searchable: true, orderable: true },
      email: { source: 'User.email', cond: :like, searchable: true, orderable: true },
      admin_action: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    records.map do |record|
      { id: record.id,
        username: render(partial: 'datatable/user_status', locals: {user: record}, formats: :html),
        email: record.email,
        admin_action: link_to(fa_icon('edit'), edit_employee_path(record), remote: true) }
    end
  end

  def get_raw_records
    @users
  end
end
