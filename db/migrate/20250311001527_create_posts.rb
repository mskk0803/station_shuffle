class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts, id: false do |t|
      t.uuid :id, primary_key: true, null: false, default: -> { "gen_random_uuid()" }
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.text :content, null: false

      t.timestamps
    end
  end
end
