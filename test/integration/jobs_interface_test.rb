require 'test_helper'

class JobsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:daenerys)
  end

  test "job interface" do
    log_in_as(@user)
    get root_path
    assert_select 'ul.pagination'
    # Invalid submission
    assert_no_difference 'Job.count' do
      post jobs_path, job: { name: "", nodes: 0, config: "minesweeper" }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    name = "Grey worm"
    assert_difference 'Job.count', 1 do
      post jobs_path, job: { name: name, nodes: 1, processors: 1,
                             config: "ansys" }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match name, response.body
    # Delete a job.
    first_job = @user.jobs.page(1).first
    assert_select "a[href=?][data-method='delete']", job_path(first_job)
    assert_difference 'Job.count', -1 do
      delete job_path(first_job)
    end
    # Visit a different user.
    get user_path(users(:jon))
    assert_select "a[href=?][data-method='delete']", job_path(first_job),
      count: 0
  end
end
