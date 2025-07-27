class RenameIncludesShippingToPriceIncludesShippingInListings < ActiveRecord::Migration[8.0]
  def change
    rename_column :listings, :includes_shipping, :price_includes_shipping
  end
end
