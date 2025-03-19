class CreateCheckins < ActiveRecord::Migration[7.2]
  def change
    create_table :checkins, id: false do |t|
      t.timestamps
      t.uuid :id, primary_key: true, null: false, default: -> { "gen_random_uuid()" }
      t.uuid :user_id, null: false
      t.string :station, null: false
    end

    add_foreign_key :checkins, :users, column: :user_id, primary_key: :id
  end
end
