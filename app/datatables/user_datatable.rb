class UserDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegator :@view, :edit_employee_path
  def_delegator :@view, :link_to

  def initialize(params, opts = {})
    @users = opts[:users]
    @view = opts[:view_context]
    super
  end

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id: { source: 'User.id', cond: :eq, searchable: true, orderable: true },
      username: { source: 'User.username', cond: :like, searchable: true, orderable: true },
      email: { source: 'User.email', cond: :like, searchable: true, orderable: true }
    }
  end

  def data
    records.map do |record|
      { id: record.id,
        username: link_to(record.username, edit_employee_path(record)),
        email: record.email }
    end
  end

  def get_raw_records
    @users
  end
end
