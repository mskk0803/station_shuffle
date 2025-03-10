class ChangeDataTypeUserUidOfPost < ActiveRecord::Migration[7.2]
  def change
    change_column :posts, :user_uid, :string, null: false
  end
end
