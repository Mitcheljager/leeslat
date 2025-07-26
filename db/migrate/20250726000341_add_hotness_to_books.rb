class AddHotnessToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :hotness, :integer
  end
end
