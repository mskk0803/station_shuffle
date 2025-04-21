class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.uuid :user_id, null: false
      # 通知の種類 notifable_typeとnotifable_idを生成する
      t.references :notifable, polymorphic: true, null: false
      t.boolean :read, default: false
      t.timestamps
    end

    # 外部キー制約
    add_foreign_key :notifications, :users, column: :user_id, primary_key: :id

    # Indexを張る
    add_index :notifications, [ :user_id ]
    add_index :notifications, [ :notifable_type, :notifable_id ]
  end
end
