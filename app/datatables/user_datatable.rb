class UserDatatable < AjaxDatatablesRails::ActiveRecord
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
      email: { source: 'User.email', cond: :like, searchable: true, orderable: true }
    }
  end

  def data
    records.map do |record|
      { id: record.id,
        username: record.username,
        email: record.email }
    end
  end

  def get_raw_records
    @users
  end
end
