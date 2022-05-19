class AddThCodeToProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :th_code, :string
  end
end
