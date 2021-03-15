class CreateYxtPositions < ActiveRecord::Migration[6.0]
  def change
    create_table :yxt_positions do |t|
      t.string :position_name
      t.string :prefix_paths

      t.timestamps
    end
    add_reference :users, :yxt_position
  end
end
