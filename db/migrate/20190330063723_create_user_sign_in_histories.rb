class CreateUserSignInHistories < ActiveRecord::Migration[5.2]
  def postgresql?
    ar_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "primary").configuration_hash
    ar_config && ar_config['adapter'] == 'postgresql'
  end

  def change
    create_table :user_sign_in_histories do |t|
      t.references :user, foreign_key: true
      t.datetime :sign_in_at
      t.string :user_agent
      if postgresql?
        t.inet :sign_in_ip
      else
        t.string :sign_in_ip
      end
    end
  end
end
