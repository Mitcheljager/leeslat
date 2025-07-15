class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books, id: false do |t|
      t.string :title
      t.string :author
      t.string :isbn, primary_key: true

      t.timestamps
    end

    add_index :books, :isbn, unique: true
  end
end
