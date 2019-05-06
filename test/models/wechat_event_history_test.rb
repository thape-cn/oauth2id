require 'test_helper'

class WechatEventHistoryTest < ActiveSupport::TestCase
  test 'WechatEventHistory valid' do
    wechat_event_history = wechat_event_histories(:wechat_event_history_batch_job_result)
    assert wechat_event_history.valid?
  end
end
