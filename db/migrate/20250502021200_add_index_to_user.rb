class AddIndexToUser < ActiveRecord::Migration[7.2]
  def change
    add_index :users, :name
  end
end
