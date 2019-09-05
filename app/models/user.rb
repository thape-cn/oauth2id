class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant',
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken',
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks

  has_one :profile
  accepts_nested_attributes_for :profile

  has_many :user_allowed_applications
  accepts_nested_attributes_for :user_allowed_applications
  has_many :oauth_applications, through: :user_allowed_applications

  has_many :department_users, dependent: :destroy
  has_many :departments, through: :department_users

  has_many :position_users, dependent: :destroy
  has_many :positions, through: :position_users
  has_many :user_sign_in_histories, -> { order(id: :desc) }, dependent: :restrict_with_error

  validates :username, presence: true, exclusion: { in: %w[admin] }

  def gravatarurl
    hash = Digest::MD5.hexdigest(email)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  include Devise::JWT::RevocationStrategies::Whitelist

  def self.find_for_jwt_authentication(sub)
    find_by(email: sub)
  end

  def jwt_subject
    email
  end

  def expired_jwts
    whitelisted_jwts.where('exp <= ?', Time.now)
  end
end
