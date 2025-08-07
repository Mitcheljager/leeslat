class AddIndexToBooksHotness < ActiveRecord::Migration[8.0]
  def change
    add_index :books, :hotness
  end
end
