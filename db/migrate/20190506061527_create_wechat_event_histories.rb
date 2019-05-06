class CreateWechatEventHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :wechat_event_histories do |t|
      t.integer :create_time
      t.string :event
      t.string :change_type
      t.string :job_id
      t.string :user_id
      t.string :party_id
      t.string :tag_id
      t.text :message

      t.timestamps
    end
  end
end
