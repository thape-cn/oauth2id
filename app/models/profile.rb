class Profile < ApplicationRecord
  belongs_to :user
  HIDDEN_ATTRIBUTES = %w[id user_id created_at updated_at].freeze

  def custom_attributes
    attributes.reject { |k,v| k.in? HIDDEN_ATTRIBUTES }
  end
end
