class MovePostLevelFromPositionUserToPosition < ActiveRecord::Migration[6.1]
  def change
    remove_column :position_users, :post_level, :string
    add_column :positions, :post_level, :string
  end
end
