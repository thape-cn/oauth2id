require 'test_helper'
require 'minitest/mock'

Rails.application.load_tasks

class SyncYxtTaskTest < ActiveSupport::TestCase
  test 'uses a non-intern main position and excludes intern positions from YXT sync' do
    user = users(:user_shin)
    intern_position = Position.create!(name: '建筑实习生', b_postcode: 'intern-position')
    primary_position = Position.create!(name: '建筑师', b_postcode: 'primary-position')
    PositionUser.create!(user: user, position: intern_position, main_position: true)
    PositionUser.create!(user: user, position: primary_position, main_position: true)

    helper = Object.new
    main_position, yxt_positions = helper.send(:yxt_user_positions, user)

    assert_equal primary_position, main_position
    assert_equal [primary_position], yxt_positions
    assert_not helper.send(:yxt_intern_position?, main_position)
    assert_not helper.send(:yxt_user_disabled?, user, main_position, yxt_positions)
  end

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
