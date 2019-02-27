module ApplicationHelper
  def devise_error_messages
    return '' unless defined?(resource) && resource.errors.present?

    messages = resource.errors.full_messages.join('，')
    sentence = I18n.t('errors.messages.not_saved',
                      count: resource.errors.count,
                      resource: resource.class.model_name.human.downcase)
    "#{sentence}#{messages}"
  end
end
