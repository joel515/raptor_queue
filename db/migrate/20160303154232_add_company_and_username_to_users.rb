class AddCompanyAndUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :company, :string
    add_column :users, :username, :string
  end
end
