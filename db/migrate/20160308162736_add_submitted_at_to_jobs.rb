class AddSubmittedAtToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :submitted_at, :string, default: '---'
  end
end
