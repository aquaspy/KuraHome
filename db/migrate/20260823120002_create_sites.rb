class CreateSites < ActiveRecord::Migration[8.1]
  def change
    create_table :sites do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :title, null: false
      t.string :url, null: false
      t.string :hint, null: false, default: ""
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :sites, [ :profile_id, :position ]
  end
end
