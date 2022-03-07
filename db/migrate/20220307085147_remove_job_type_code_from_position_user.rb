class RemoveJobTypeCodeFromPositionUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :position_users, :job_type_code, :string
    add_column :positions, :job_type_code, :string
  end
end
