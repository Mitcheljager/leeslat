class AddSlugAndDescriptionToAuthors < ActiveRecord::Migration[8.0]
  def change
    add_column :authors, :slug, :string
    add_column :authors, :description, :string
  end
end
