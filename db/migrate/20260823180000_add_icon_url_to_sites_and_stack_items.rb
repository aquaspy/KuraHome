class AddIconUrlToSitesAndStackItems < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :icon_url, :string, null: false, default: ""
    add_column :stack_items, :icon_url, :string, null: false, default: ""
  end
end
