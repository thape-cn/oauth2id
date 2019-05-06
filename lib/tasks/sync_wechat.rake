require 'csv'

namespace :sync_wechat do
  desc 'Replace party with oauth2id departments'
  task replaceparty: :environment do
    replaceparty_file = 'batch_department2party.csv'

    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_department_ids = Department.where(managed_by_department_id: second_level_department_ids).pluck(:id)

    CSV.open(replaceparty_file, 'w') do |csv|
      csv << %w(部门名称 部门ID 父部门ID 排序)
      Department.where(id: root_department_ids).order(:id).each do |d|
        csv << [d.name.truncate(32), d.id, 0, d.position]
      end
      Department.where(id: first_level_department_ids).order(:id).each do |d|
        csv << [d.name.truncate(32), d.id, d.managed_by_department_id, d.position]
      end
      Department.where(id: second_level_department_ids).order(:id).each do |d|
        csv << [d.name.truncate(32), d.id, d.managed_by_department_id, d.position]
      end
      Department.where(id: third_level_department_ids).order(:id).each do |d|
        csv << [d.name.truncate(32), d.id, d.managed_by_department_id, d.position]
      end
    end
    media_id = Wechat.api.media_create('file', replaceparty_file)['media_id']
    job_id = Wechat.api.batch_replaceparty(media_id)['jobid']
    puts "running job_id: #{job_id}"
    puts Wechat.api.batch_job_result(job_id)
  end
end
