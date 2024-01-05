class PositionDatatable < ApplicationDatatable
  extend Forwardable

  def initialize(params, opts = {})
    @positions = opts[:positions]
    super
  end

  def view_columns
    @view_columns ||= {
      id: { source: 'Position.id', cond: :eq, searchable: true, orderable: true },
      name: { source: 'Position.name', cond: :like, searchable: true, orderable: true },
      functional_category: { source: 'Position.functional_category', cond: :like, searchable: true, orderable: true },
      admin_action: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    records.map do |record|
      { id: record.id,
        name: record.name,
        functional_category: record.functional_category,
        admin_action: nil }
    end
  end

  def get_raw_records
    @positions
  end
end
