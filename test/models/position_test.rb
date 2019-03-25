require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  test 'Position develop manager valid' do
    position_dev_manager = positions(:position_dev_manager)
    assert position_dev_manager.valid?
    assert_equal position_dev_manager.users.count, 1
  end

  test 'Position strategic development supervisor valid' do
    strategic_development_supervisor = positions(:position_strategic_development_supervisor)
    assert strategic_development_supervisor.valid?
    assert_equal strategic_development_supervisor.users.count, 1
  end
end
