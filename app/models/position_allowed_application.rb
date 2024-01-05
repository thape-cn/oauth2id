class PositionAllowedApplication < ApplicationRecord
  belongs_to :position
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application'
end
