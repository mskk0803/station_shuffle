class CreateLikes < ActiveRecord::Migration[7.2]
  def change
    create_table :likes do |t|
      t.uuid :user_id, null: false
      t.uuid :post_id, null: false

      t.timestamps
    end
    # 外部キー制約
    add_foreign_key :likes, :users, column: :user_id, primary_key: :id
    add_foreign_key :likes, :posts, column: :post_id, primary_key: :id
    # ユニークキー
    add_index :likes, [ :user_id, :post_id ], unique: true
  end
end
