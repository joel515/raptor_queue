class AddVersionToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :version, :string
  end
end
