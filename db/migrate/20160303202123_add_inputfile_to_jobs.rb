class AddInputfileToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :inputfile, :string
  end
end
