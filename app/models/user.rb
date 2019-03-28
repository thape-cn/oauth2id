class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  include_devise_modules = if Rails.env.test?
    %i[database_authenticatable registerable recoverable
       rememberable trackable validatable confirmable lockable]
  else
    %i[ldap_authenticatable recoverable
       rememberable trackable validatable lockable]
  end
  devise *include_devise_modules

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

  validates :username, presence: true, exclusion: { in: %w[admin] }

  def gravatarurl
    hash = Digest::MD5.hexdigest(email)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  # Will be called at gem devise_ldap_authenticatable, lib/devise_ldap_authenticatable/model.rb:107
  def ldap_before_save
    li = Devise::LDAP::Adapter.get_ldap_entry(self.username)
    self.username = li[:samaccountname].first.to_s
    self.email = li[:mail].first.to_s
  end
end
