class AddTimeAndLocationToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :time, :string unless column_exists?(:events, :time)
    add_column :events, :location, :string unless column_exists?(:events, :location)
  end
end
