class AddConditionDetailsToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :condition_details, :string
  end
end
