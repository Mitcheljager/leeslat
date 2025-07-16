require_relative "../base"
require "nokogiri"

def scrape_amazon(isbn)
  basepath = "https://www.amazon.nl"
  search_document = get_document("#{basepath}/s?k=#{isbn}")
  first_search_item_path = search_document.css("[role='listitem'] a").first.attribute("href").value
  url = basepath + first_search_item_path

  puts "Running Amazon for: " + url

  document = get_document(url)

  price = document.css(".priceToPay span").first.text.strip.gsub("€", "").gsub(",", ".")
  image = document.css("#landingImage").first.attribute("src").value.strip

  puts isbn
  puts price
  puts image

  save_result("Amazon", isbn, price, "EUR", url)
end
