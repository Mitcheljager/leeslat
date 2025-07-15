class CreateSources < ActiveRecord::Migration[8.0]
  def change
    create_table :sources do |t|
      t.string :name
      t.string :slug
      t.string :base_url

      t.timestamps
    end

    add_index :sources, :slug, unique: true
  end
end
