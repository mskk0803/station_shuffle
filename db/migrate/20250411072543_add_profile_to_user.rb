class AddProfileToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :profile, :text
  end
end
