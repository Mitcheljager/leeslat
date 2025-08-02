class CreateRequestedIsbns < ActiveRecord::Migration[8.0]
  def change
    create_table :requested_isbns do |t|
      t.string :isbn
      t.string :status

      t.timestamps
    end
  end
end
