class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  include_devise_modules = if Rails.env.test?
                             %i[database_authenticatable
                                registerable
                                recoverable rememberable trackable validatable
                                confirmable lockable jwt_authenticatable]
                           else
                             %i[ldap_authenticatable
                                recoverable rememberable trackable validatable
                                lockable jwt_authenticatable]
                           end
  devise(*include_devise_modules, jwt_revocation_strategy: self)

  attr_accessor :skip_password_validation  # virtual attribute to skip password validation while saving

  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant',
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken',
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  has_many :user_allowed_applications, dependent: :destroy
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

  include Devise::JWT::RevocationStrategies::Allowlist

  def self.find_for_jwt_authentication(sub)
    find_by(email: sub)
  end

  def jwt_subject
    email
  end

  def expired_jwts
    allowlisted_jwts.where('exp <= ?', Time.now)
  end

  # Will be called at gem devise_ldap_authenticatable, lib/devise_ldap_authenticatable/model.rb:107
  def ldap_before_save
    li = Devise::LDAP::Adapter.get_ldap_entry(self.username)
    self.username = li[:samaccountname].first.to_s
    self.email = li[:mail].first.to_s
    errors.add(:email, 'Email is empty from AD') if self.email.blank?
  end

  def after_ldap_authentication
    li = Devise::LDAP::Adapter.get_ldap_entry(self.username)
    desk_phone = li[:telephonenumber].first.to_s
    update_columns(desk_phone: desk_phone)
    return fail(:invalid) if li[:mail].blank?
  end

  protected

  def password_required?
    return false if skip_password_validation
    super
  end
end
