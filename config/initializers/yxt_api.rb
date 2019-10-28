if Rails.env.development?
  Yxt.apikey     = Rails.application.credentials.yxt_test_apikey!
  Yxt.secretkey  = Rails.application.credentials.yxt_test_secretkey!
  Yxt.base_url = 'http://api-udp-adel.yunxuetang.com.cn'
else
  Yxt.apikey     = Rails.application.credentials.yxt_apikey!
  Yxt.secretkey  = Rails.application.credentials.yxt_secretkey!
  Yxt.base_url = 'https://api-qidac1.yunxuetang.cn'
end
