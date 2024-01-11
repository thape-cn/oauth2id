class Department < ApplicationRecord
  has_many :department_users, dependent: :destroy
  has_many :users, through: :department_users
  belongs_to :managed_by_department, class_name: :Department, optional: true
  has_many :managed_departments, class_name: :Department, foreign_key: :managed_by_department_id

  has_many :department_allowed_applications, dependent: :destroy
  has_many :oauth_applications, through: :department_allowed_applications

  def allowed_application_ids
    @allowed_application_ids ||= department_allowed_applications.collect(&:oauth_application_id)
  end

  def allowed_application_ids=(values)
    select_values = Array(values).reject(&:blank?).map(&:to_i)
    if new_record?
      (select_values - allowed_application_ids).each do |to_new_id|
        department_allowed_applications.build(oauth_application_id: to_new_id)
      end
    else
      (allowed_application_ids - select_values).each do |to_destroy_id|
        department_allowed_applications.find_by(oauth_application_id: to_destroy_id).destroy
      end
      (select_values - allowed_application_ids).each do |to_add_id|
        department_allowed_applications.create(oauth_application_id: to_add_id)
      end
    end
  end

  def all_managed_department_ids
    all_ids = ids = [id]
    loop do
      ids = Department.where(managed_by_department_id: ids).pluck(:id)
      break if ids.empty?
      all_ids << ids
    end
    all_ids.flatten.uniq
  end
end
