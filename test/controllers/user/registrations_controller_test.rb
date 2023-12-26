class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    UserSignInHistory.destroy_all # Need to destroy it first, because of restrict_with_error dependent
    User.destroy_all
  end

  test 'should register a new user' do
    assert_difference -> { User.count }, 1 do
      post user_registration_path, params: { user: { username: 'firstuser', email: 'firstuser@example.com', password: '12345678aa', password_confirmation: '12345678aa' } }
      assert_response :redirect
    end
  end
end
