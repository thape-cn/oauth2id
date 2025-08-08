class Profile < ApplicationRecord
  belongs_to :user
  HIDDEN_ATTRIBUTES = %w[id user_id created_at updated_at].freeze

  def custom_attributes
    attributes.reject { |k,v| k.in? HIDDEN_ATTRIBUTES }
  end

  def self.from_omniauth(auth)
    find_by(wecom_id: auth.uid)
  end
end
