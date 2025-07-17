class AddAdditionFieldsToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :number_of_pages, :integer
    add_column :listings, :description, :string
  end
end
