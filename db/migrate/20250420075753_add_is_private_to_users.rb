class AddIsPrivateToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :is_private, :boolean, default: false, null: false
  end
end
