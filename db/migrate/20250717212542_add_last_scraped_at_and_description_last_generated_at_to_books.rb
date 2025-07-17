class AddLastScrapedAtAndDescriptionLastGeneratedAtToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :last_scraped_at, :datetime
    add_column :books, :description_last_generated_at, :datetime
  end
end
