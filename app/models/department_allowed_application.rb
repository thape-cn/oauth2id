class DepartmentAllowedApplication < ApplicationRecord
  belongs_to :department
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application'
end
