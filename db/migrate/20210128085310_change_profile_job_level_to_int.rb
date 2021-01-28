class ChangeProfileJobLevelToInt < ActiveRecord::Migration[6.0]
  def change
    Profile.where(job_level: '/').update_all(job_level: 0)
    change_column :profiles, :job_level, :integer
  end
end
