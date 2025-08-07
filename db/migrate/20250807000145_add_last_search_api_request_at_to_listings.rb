class AddLastSearchApiRequestAtToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :last_search_api_request_at, :datetime
  end
end
