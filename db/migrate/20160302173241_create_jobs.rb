class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :pid
      t.string :jobdir
      t.string :status, default: "Unsubmitted"
      t.string :config
      t.integer :nodes, default: 1
      t.integer :processors, default: 1
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :jobs, [:user_id, :created_at]
  end
end
