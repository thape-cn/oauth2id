class AddHideAgentsNamesToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :profiles, :hide_agents_names, :string, default: 'bid-assistant,7777'
  end
end
