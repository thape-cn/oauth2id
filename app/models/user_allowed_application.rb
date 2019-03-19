class UserAllowedApplication < ApplicationRecord
  belongs_to :user
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application'
end
