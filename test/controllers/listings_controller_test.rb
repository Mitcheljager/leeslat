require "test_helper"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @listing = listings(:one)
  end

  test "should get index" do
    get listings_url
    assert_response :success
  end

  test "should get new" do
    get new_listing_url
    assert_response :success
  end

  test "should create listing" do
    assert_difference("Listing.count") do
      post listings_url, params: { listing: { book_id: @listing.book_id, currency: @listing.currency, last_scraped_at: @listing.last_scraped_at, price: @listing.price, source_id: @listing.source_id, url: @listing.url } }
    end

    assert_redirected_to listing_url(Listing.last)
  end

  test "should show listing" do
    get listing_url(@listing)
    assert_response :success
  end

  test "should get edit" do
    get edit_listing_url(@listing)
    assert_response :success
  end

  test "should update listing" do
    patch listing_url(@listing), params: { listing: { book_id: @listing.book_id, currency: @listing.currency, last_scraped_at: @listing.last_scraped_at, price: @listing.price, source_id: @listing.source_id, url: @listing.url } }
    assert_redirected_to listing_url(@listing)
  end

  test "should destroy listing" do
    assert_difference("Listing.count", -1) do
      delete listing_url(@listing)
    end

    assert_redirected_to listings_url
  end
end
