class AddLastScrapedSuccessfulToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :was_last_scrape_successful, :boolean
  end
end
