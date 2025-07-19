class AddConditionToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :condition, :integer, default: 0, null: false
  end
end
