class CreateUpvotes < ActiveRecord::Migration[7.1]
  def change
    create_table :upvotes do |t|
      t.references :event, null: false, foreign_key: true
      t.string :email, null: false
      t.string :username, null: false
      t.timestamps
    end

    add_index :upvotes, [:event_id, :email], unique: true
  end
end