class RenameLastScrapedAtToLastScrapeFinishedAtInBooks < ActiveRecord::Migration[8.0]
  def change
    rename_column :books, :last_scraped_at, :last_scrape_finished_at
  end
end
