require_relative "base"
require "nokogiri"

search_document = get_document("https://www.amazon.nl/s?k=9781529124309")
first_search_item_path = search_document.css("[role='listitem'] a").first.attribute("href").value

document = get_document("https://www.amazon.nl" + first_search_item_path)

title = document.css("h1 #productTitle").text.strip
isbn = document.css("[data-rpi-attribute-ref-tag='dbs_dp_rpi_r_d_book_details_isbn13'] .rpi-attribute-value").text.strip.gsub("-", "")
price = document.css(".priceToPay").first.text.strip.gsub("€", "").gsub(",", ".")
image = document.css("#landingImage").first.attribute("src").value.strip

puts title
puts isbn
puts price
puts image

save_result("Amazon", isbn, title, "author", price, "EUR", "some-url")
