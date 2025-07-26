class AddIncludesShippingToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :includes_shipping, :boolean, default: false
  end
end
