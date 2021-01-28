class AddPostLevelTypeCodeToPositionUser < ActiveRecord::Migration[6.0]
  def change
    add_column :position_users, :post_level, :string
    add_column :position_users, :job_type_code, :string
  end
end
