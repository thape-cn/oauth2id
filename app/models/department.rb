class Department < ApplicationRecord
  has_many :department_users, dependent: :destroy
  has_many :users, through: :department_users
  belongs_to :managed_by_department, class_name: :Department, optional: true
  has_many :managed_departments, class_name: :Department, foreign_key: :managed_by_department_id
end
