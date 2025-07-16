class AddAdditionFieldsToBook < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :language, :string
    add_column :books, :number_of_pages, :integer, default: 0
    add_column :books, :subtitle, :string
    add_column :books, :description, :string
    add_column :books, :format, :integer, default: 0, null: false
  end
end
