class AddKeywordsToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :keywords, :string
  end
end
