class AddCoverLastScrapedAtToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :cover_last_scraped_at, :datetime
  end
end
