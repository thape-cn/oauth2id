namespace :gitlab do
  desc 'Update gitlab all users to known status'
  task update_users: :environment do
    gitlab_users = Gitlab.users(per_page: 10)
    gitlab_users.auto_paginate do |g_user|
      user = User.find_by email: g_user.email
      if user&.profile.present?
        Gitlab.edit_user(g_user.id, { name: user.profile.chinese_name })
      else
        puts "User: #{g_user.username} email: #{g_user.email} not found"
      end
    end
  end
end
