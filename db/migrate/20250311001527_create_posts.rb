class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts, id: false do |t|
      t.uuid :id, primary_key: true, null: false, default: -> { "gen_random_uuid()" }
      t.uuid :user_id, null: false
      t.text :content, null: false

      t.timestamps
    end
    add_foreign_key :posts, :users, column: :user_id, primary_key: :id
  end
end
