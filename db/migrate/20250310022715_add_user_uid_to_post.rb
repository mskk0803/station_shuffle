class AddUserUidToPost < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :user_uid, :string
  end
end
