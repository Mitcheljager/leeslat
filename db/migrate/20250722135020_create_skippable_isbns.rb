class CreateSkippableIsbns < ActiveRecord::Migration[8.0]
  def change
    create_table :skippable_isbns do |t|
      t.string :isbn
      t.boolean :permanent

      t.timestamps
    end
  end
end
