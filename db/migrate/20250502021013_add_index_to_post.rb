class AddIndexToPost < ActiveRecord::Migration[7.2]
  def change
    add_index :posts, :created_at
  end
end
