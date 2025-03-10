class RemoveUserIdFromPost < ActiveRecord::Migration[7.2]
  def change
    remove_column :posts, :user_id, :bigint
  end
end
