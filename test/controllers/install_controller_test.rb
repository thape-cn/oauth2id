require 'test_helper'

class InstallControllerTest < ActionDispatch::IntegrationTest

  def clean_users
    UserSignInHistory.destroy_all # Need to destroy it first, because of restrict_with_error dependent
    User.destroy_all
  end

  test 'should redirect to root url if users record exist' do
    get install_path
    assert_response :redirect
  end

  test 'should redirect to install page if no user record filled' do
    clean_users

    get root_path
    assert_response :redirect

    get install_path
    assert_response :success
  end

  test 'should get install step1 page' do
    clean_users

    get install_step1_path
    assert_response :success
  end

  test 'should get install step2 page' do
    clean_users

    get install_step2_path
    assert_response :success
  end

  test 'should get install step3 page' do
    clean_users

    get install_step3_path
    assert_response :success
  end

  test 'should create an admin user in step 3' do
    clean_users

    assert_difference -> { User.count }, 1 do
      post install_step3_path, params: {
        user: { username: 'firstadmin', email: 'firstadmin@example.com', password: '123abc1234', password_confirmation: '123abc1234' }
      }
      user = User.first
      assert_equal 'firstadmin', user.username
      assert_equal true, user.admin?
      assert_equal true, user.confirmed?
      assert_response :redirect
    end

  end


end
