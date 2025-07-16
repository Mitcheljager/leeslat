require_relative "base"
require "nokogiri"

def scrape_amazon(isbn)
  basepath = "https://www.amazon.nl"
  search_document = get_document("#{basepath}/s?k=#{isbn}")
  first_search_item_path = search_document.css("[role='listitem'] a").first.attribute("href").value

  puts "Running Amazon for: " + basepath + first_search_item_path

  document = get_document(basepath + first_search_item_path)

  isbn = document.css("[data-rpi-attribute-ref-tag='dbs_dp_rpi_r_d_book_details_isbn13'] .rpi-attribute-value").text.strip.gsub("-", "")
  price = document.css(".priceToPay span").first.text.strip.gsub("€", "").gsub(",", ".")
  image = document.css("#landingImage").first.attribute("src").value.strip

  puts isbn
  puts price
  puts image

  save_result("Amazon", isbn, price, "EUR", "some-url")
end
