class RemoveJobDefaults < ActiveRecord::Migration
  def change
    change_column_default :jobs, :nodes, nil
    change_column_default :jobs, :processors, nil
  end
end
