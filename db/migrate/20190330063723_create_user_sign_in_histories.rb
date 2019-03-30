class CreateUserSignInHistories < ActiveRecord::Migration[5.2]
  def postgresql?
    config = ActiveRecord::Base.configurations[Rails.env]
    config && config['adapter'] == 'postgresql'
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
