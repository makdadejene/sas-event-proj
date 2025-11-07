class ChangeTagsToArrayInEvents < ActiveRecord::Migration[7.1]
  def change
    remove_column :events, :tags, :string
    add_column :events, :tags, :string, array: true, default: []
  end
end
