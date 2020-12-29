namespace :sync_wechat do
  desc 'Replace party with oauth2id departments'
  task :merge_user, %i[to_merge_user_id target_user_id] => [:environment] do |_task, args|
    to_merge_user = User.find args[:to_merge_user_id]
    target_user = User.find args[:target_user_id]
    if to_merge_user.present? && target_user.present?
      puts "Now will merge #{to_merge_user} into #{target_user}"
    else
      puts "To_merge_user: #{to_merge_user} or target_user: #{target_user} is blank"
    end
  end
end
