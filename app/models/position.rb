class Position < ApplicationRecord
  has_many :position_users, dependent: :destroy
  has_many :users, through: :position_users

  has_many :position_allowed_applications, dependent: :destroy
  has_many :oauth_applications, through: :position_allowed_applications
end
