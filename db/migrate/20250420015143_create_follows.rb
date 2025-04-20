class CreateFollows < ActiveRecord::Migration[7.2]
  def change
    create_table :follows do |t|
      # フォローした側のユーザーID
      t.uuid :follows_user_id, null: false
      # フォローされた側のユーザーID
      t.uuid :followed_user_id, null: false
      t.timestamps
    end
    # 外部キー制約
    add_foreign_key :follows, :users, column: :follows_user_id, primary_key: :id
    add_foreign_key :follows, :users, column: :followed_user_id, primary_key: :id
    # ユニーク制約を追加
    add_index :follows, [ :follows_user_id, :followed_user_id ], unique: true
  end
end
