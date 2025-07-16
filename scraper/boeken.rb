require_relative "base"
require "nokogiri"

def scrape_boeken(isbn)
  document = get_document("https://www.boeken.nl/boeken/9780007299263/howls-moving-castle")

  isbn = document.css(".field-name-field-isbn").first.text.strip
  price = document.css(".product-info .uc-price").first.text.strip
  image = document.css(".group-cover-and-photos .field-name-field-cover img").first.attribute("data-src").value.strip

  puts isbn
  puts price
  puts image
end
