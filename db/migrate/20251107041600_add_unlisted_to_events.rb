class AddUnlistedToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :unlisted, :boolean
  end
end
