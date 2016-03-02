require 'test_helper'

class JobsControllerTest < ActionController::TestCase

  def setup
    @job = jobs(:drogon)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Job.count' do
      post :create, job: { content: "Test" }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Job.count' do
      delete :destroy, id: @job
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:daenerys))
    job = jobs(:longclaw)
    assert_no_difference 'Job.count' do
      delete :destroy, id: job
    end
    assert_redirected_to root_url
  end
end
