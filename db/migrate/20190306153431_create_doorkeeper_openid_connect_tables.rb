class CreateDoorkeeperOpenidConnectTables < ActiveRecord::Migration[5.2]
  def mysql?
    ar_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "primary").configuration_hash
    ar_config && ar_config[:adapter] == 'mysql2'
  end

  def change
    create_table :oauth_openid_requests do |t|
      if mysql?
        t.bigint :access_grant_id, null: false
      else
        t.integer :access_grant_id, null: false
      end
      t.string :nonce, null: false
    end

    add_foreign_key(
      :oauth_openid_requests,
      :oauth_access_grants,
      column: :access_grant_id
    )
  end
end
