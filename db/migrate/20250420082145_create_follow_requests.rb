class CreateFollowRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :follow_requests do |t|
      # フォローリクエストを送信したユーザーのID
      t.uuid :requester_id, null: false
      # フォローリクエストを受信したユーザーのID
      t.uuid :requestee_id, null: false

      # フォローリクエストの状態
      # 0: 保留中, 1: 承認
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    # 外部キー制約
    add_foreign_key :follow_requests, :users, column: :requester_id, primary_key: :id
    add_foreign_key :follow_requests, :users, column: :requestee_id, primary_key: :id
    # ユニーク制約を追加
    add_index :follow_requests, [ :requester_id, :requestee_id ], unique: true
  end
end
