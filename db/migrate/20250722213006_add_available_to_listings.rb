class AddAvailableToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :available, :boolean, default: false
  end
end
