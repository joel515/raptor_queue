require 'test_helper'

class JobTest < ActiveSupport::TestCase

  def setup
    @user = users(:daenerys)
    @job = @user.jobs.build(name: "Drogon")
  end

  test "should be valid" do
    assert @job.valid?
  end

  test "user id should be present" do
    @job.user_id = nil
    assert_not @job.valid?
  end

  test "name should be present" do
    @job.name = " " * 5
    assert_not @job.valid?
  end

  test "name should be at most 15 characters" do
    @job.name = "a" * 16
    assert_not @job.valid?
  end

  test "status should be present" do
    @job.status = nil
    assert_not @job.valid?
  end

  test "status should be included in accepted hash" do
    @job.status = "Discombobulated"
    assert_not @job.valid?
  end

  test "node count should be present" do
    @job.nodes = nil
    assert_not @job.valid?
  end

  test "node count should be within range" do
    @job.nodes = 0
    assert_not @job.valid?
    @job.nodes = 33
    assert_not @job.valid?
  end

  test "processors per node count should be present" do
    @job.processors = nil
    assert_not @job.valid?
  end

  test "processors per node count should be within range" do
    @job.processors = 0
    assert_not @job.valid?
    @job.processors = 17
    assert_not @job.valid?
  end

  test "order should be most recent first" do
    assert_equal jobs(:most_recent), Job.first
  end
end
