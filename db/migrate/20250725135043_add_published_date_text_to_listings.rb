class AddPublishedDateTextToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :published_date_text, :string
  end
end
