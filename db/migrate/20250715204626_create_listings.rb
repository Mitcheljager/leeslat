class CreateListings < ActiveRecord::Migration[8.0]
  def change
    create_table :listings do |t|
      t.integer :book_id
      t.integer :source_id
      t.float :price
      t.string :currency
      t.string :url
      t.datetime :last_scraped_at

      t.timestamps
    end
  end
end
