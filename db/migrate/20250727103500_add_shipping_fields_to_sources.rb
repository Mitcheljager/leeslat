class AddShippingFieldsToSources < ActiveRecord::Migration[8.0]
  def change
    add_column :sources, :shipping_cost, :float, default: 0
    add_column :sources, :shipping_cost_currency, :string, default: "EUR"
    add_column :sources, :shipping_cost_free_from_price, :float, default: 0
    add_column :sources, :shipping_cost_free_from_quantity, :integer, default: 0
  end
end
