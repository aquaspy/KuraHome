class CreateStackItems < ActiveRecord::Migration[8.1]
  def change
    create_table :stack_items do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :category, null: false
      t.string :choice, null: false
      t.string :origin, null: false, default: ""
      t.string :note, null: false, default: ""
      t.string :url, null: false, default: ""
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :stack_items, [ :profile_id, :position ]
  end
end
