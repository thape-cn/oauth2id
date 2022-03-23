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

  desc 'Clean the duplicate positions'
  task clean_duplicate_position: :environment do
    clean_records = Position.all
                            .group(:nc_pk_post)
                            .having('count(*) > 1')
                            .count

    clean_records.each do |r|
      nc_pk_post = r[0]

      to_remove_records = Position.where(nc_pk_post: nc_pk_post)
      to_remove_records.each do |position|
        next unless position.users.count.zero?

        position.destroy
      end
    end
  end

  desc 'Merge duplicate positions'
  task merge_duplicate_position: :environment do
    clean_records = Position.all
                            .group(:nc_pk_post)
                            .having('count(*) > 1')
                            .count

    clean_records.each do |r|
      nc_pk_post = r[0]

      to_remove_records = Position.where(nc_pk_post: nc_pk_post).to_a
      head, *tail = to_remove_records

      PositionUser.where(position_id: tail.collect(&:id)).update_all(position_id: head.id)
    end
  end
end
