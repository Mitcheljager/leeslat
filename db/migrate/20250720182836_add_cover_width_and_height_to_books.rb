class AddCoverWidthAndHeightToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :cover_original_width, :integer
    add_column :books, :cover_original_height, :integer
  end
end
