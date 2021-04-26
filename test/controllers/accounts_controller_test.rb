require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get customize" do
    get accounts_customize_url
    assert_response :success
  end

end
