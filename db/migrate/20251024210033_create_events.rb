class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :title
      t.date :date
      t.time :time
      t.string :tags
      t.text :description

      t.timestamps
    end
  end
end
