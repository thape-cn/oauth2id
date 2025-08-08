class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  include_devise_modules = if Rails.env.test?
                             %i[database_authenticatable omniauthable
                                registerable
                                recoverable rememberable trackable validatable
                                confirmable lockable jwt_authenticatable]
                           else
                             %i[ldap_authenticatable omniauthable
                                recoverable rememberable trackable validatable
                                lockable jwt_authenticatable]
                           end
  devise(*include_devise_modules, jwt_revocation_strategy: self, omniauth_providers: [:qiye_web])

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
  belongs_to :yxt_position, optional: true
  has_many :user_sign_in_histories, -> { order(id: :desc) }, dependent: :restrict_with_error

  validates :username, presence: true, exclusion: { in: %w[admin] }

  def gravatarurl
    hash = Digest::MD5.hexdigest(email)
    "https://unicornify.pictures/avatar/#{hash}?s=128"
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
    li = Devise::LDAP::Adapter.get_ldap_entry(username)
    self.username = li[:samaccountname].first.to_s
    if li[:dn][0].include?('功能账户')
      self.email = "#{username}@thape.com.cn"
    else
      self.email = li[:mail].first.to_s
    end
    self.windows_sid = get_sid_string(li[:objectsid].first)
    errors.add(:email, 'Email is empty from AD') if email.blank?
  end

  def after_ldap_authentication
    li = Devise::LDAP::Adapter.get_ldap_entry(self.username)
    desk_phone = li[:telephonenumber].first.to_s
    update_columns(desk_phone: desk_phone)
    is_function_account = li[:dn][0].include?('功能账户')
    update_columns(is_function_account: true) if is_function_account
    Rails.logger.debug "LDAP title: #{li[:title]}"
    Rails.logger.debug "LDAP mail: #{li[:mail]}"
    update_columns(windows_sid: get_sid_string(li[:objectsid].first))
    return fail(:invalid) unless li[:mail].present? || li[:title].include?('司机') || li[:title].include?('驾驶员') || li[:title].include?('实习生') || is_function_account
  end

  def chinese_name
    profile&.chinese_name
  end

  def job_title
    main_position = position_users.find_by(main_position: true)&.position
    main_position = position_users.last&.position if main_position.nil?
    main_position&.name
  end

  def job_company
    main_position = position_users.find_by(main_position: true)&.position
    main_position = position_users.last&.position if main_position.nil?
    main_position&.company_name
  end

  def last_department_name
    departments.last&.name
  end

  def yxt_user_name
    yxt_name = profile&.wecom_id || username
    case yxt_name
    when 'xulutmp' # we can not change wecom_id once created
      'xulu5'
    when 'guojianhuatmp'
      'guojianhua'
    else
      yxt_name
    end
  end

  def self.from_omniauth(auth)
    Rails.logger.info("User.from_omniauth auth=#{auth.inspect}")
    profile = Profile.find_by(wecom_id: auth.uid)
    if profile.present?
      profile.user
    else
      User.find_by(username: auth.uid)
    end
  end

  protected

  def password_required?
    return false if skip_password_validation
    super
  end

  private

  def get_sid_string(data)
    sid = []
    sid << data[0].to_s

    rid = ''
    6.downto(1) do |i|
      rid += byte2hex(data[i, 1][0])
    end
    sid << rid.to_i.to_s

    sid += data.unpack('bbbbbbbbV*')[8..]
    windows_sid = "S-#{sid.join('-')}"
    windows_sid[6..-1]
  end

  def byte2hex(b)
    ret = '%x' % (b.to_i & 0xff)
    ret = '0' + ret if ret.length < 2
    ret
  end
end
