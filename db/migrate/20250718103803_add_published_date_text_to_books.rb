class AddPublishedDateTextToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :published_date_text, :string
  end
end
