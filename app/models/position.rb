class Position < ApplicationRecord
  has_many :position_users, dependent: :destroy
  has_many :users, through: :position_users

  has_many :position_allowed_applications, dependent: :destroy
  has_many :oauth_applications, through: :position_allowed_applications

  belongs_to :department, optional: true

  def allowed_application_ids
    @allowed_application_ids ||= position_allowed_applications.collect(&:oauth_application_id)
  end

  def allowed_application_ids=(values)
    select_values = Array(values).reject(&:blank?).map(&:to_i)
    if new_record?
      (select_values - allowed_application_ids).each do |to_new_id|
        position_allowed_applications.build(oauth_application_id: to_new_id)
      end
    else
      (allowed_application_ids - select_values).each do |to_destroy_id|
        position_allowed_applications.find_by(oauth_application_id: to_destroy_id).destroy
      end
      (select_values - allowed_application_ids).each do |to_add_id|
        position_allowed_applications.create(oauth_application_id: to_add_id)
      end
    end
  end
end
