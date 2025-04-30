class AddStationToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :station, :string
  end
end
