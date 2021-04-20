class AddMajorToProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :major_code, :string
    add_column :profiles, :major_name, :string
  end
end
