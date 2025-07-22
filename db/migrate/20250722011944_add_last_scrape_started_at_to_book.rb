class AddLastScrapeStartedAtToBook < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :last_scrape_started_at, :datetime
  end
end
