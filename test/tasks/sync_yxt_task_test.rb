require 'test_helper'
require 'minitest/mock'

Rails.application.load_tasks

class SyncYxtTaskTest < ActiveSupport::TestCase
  test 'wecom auth bund reuses saved yxt open id without encrypt lookup' do
    user = users(:user_eric)
    user.profile.update!(yxt_open_id: 'saved-open-id')
    helper = Object.new
    bund_payload = nil

    helper.define_singleton_method(:puts) { |*_args| nil }
    helper.define_singleton_method(:yxt_wechat_agent_id) { 'agent-id' }
    helper.define_singleton_method(:print_yxt_response) { |*_args| nil }

    Yxt.stub(:openuser_userid_encrypt, ->(*) { raise 'unexpected encrypt lookup' }) do
      Yxt.stub(:auth_bund, ->(payload) { bund_payload = payload }) do
        helper.send(:sync_yxt_wecom_auth_bund, user, 'yxt-user-id')
      end
    end

    assert_equal(
      {
        agentId: 'agent-id',
        openId: 'saved-open-id',
        type: 1,
        userId: 'yxt-user-id'
      },
      bund_payload
    )
  end
end
