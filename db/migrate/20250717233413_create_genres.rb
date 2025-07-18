class CreateGenres < ActiveRecord::Migration[8.0]
  def change
    create_table :genres do |t|
      t.string :name
      t.string :slug
      t.references :parent_genre, foreign_key: { to_table: :genres }, null: true
      t.string :keywords

      t.timestamps
    end
  end
end
