class AddBooksCountToGenres < ActiveRecord::Migration[8.0]
  def up
    add_column :genres, :books_count, :integer, default: 0, null: false

    Genre.reset_column_information
    Genre.find_each do |genre|
      Genre.reset_counters(genre.id, :books)
    end
  end

  def down
    remove_column :genres, :books_count
  end
end
