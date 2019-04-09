class Position < ApplicationRecord
  has_many :position_users, dependent: :destroy
  has_many :users, through: :position_users
  belongs_to :department, optional: true
end
