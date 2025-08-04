class SetDefaultHotnessOnBooks < ActiveRecord::Migration[8.0]
  def up
    Book.where(hotness: nil).update_all(hotness: 0)

    change_column_default :books, :hotness, 0
    change_column_null :books, :hotness, false
  end

  def down
    change_column_null :books, :hotness, true
    change_column_default :books, :hotness, nil
  end
end
