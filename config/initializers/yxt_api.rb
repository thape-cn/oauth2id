if Rails.env.development?
  Yxt.app_id = Rails.application.credentials.yxt_test_app_id!
  Yxt.app_secret = Rails.application.credentials.yxt_test_app_secret!
  Yxt.api_origin_url = 'https://openapi.yunxuetang.cn'
  Yxt.token_cache_file = '/tmp/yxt-access-token-your_app_id.json'
else
  Yxt.app_id = Rails.application.credentials.yxt_apikey!
  Yxt.app_secret = Rails.application.credentials.yxt_secretkey!
  Yxt.api_origin_url = 'https://openapi.yunxuetang.cn'
end
