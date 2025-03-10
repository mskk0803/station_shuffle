class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.string :uid, null: false, primary_key: true
      t.text :content, null: false
      t.timestamps
    end
  end
end
