require_relative "../base"
require "nokogiri"

def scrape_amazon(isbn)
  basepath = "https://www.amazon.nl"
  search_document = get_document("#{basepath}/s?k=#{isbn}")
  first_search_item_path = search_document.css("[role='listitem'] a").first.attribute("href").value
  url = basepath + first_search_item_path

  puts "Running Amazon for: " + url

  document = get_document(url)

  price_text = document.at_css("#tmm-grid-swatch-PAPERBACK")&.text
  price = price_text.to_s.gsub(/[[:space:]]/, "").gsub("€", "").strip.gsub(",", ".").gsub("Paperback", "").strip

  if price.blank?
    price_text = document.at_css(".priceToPay span")&.text
    price = price_text.to_s.gsub("€", "").gsub(",", ".").strip
  end

  image = document.css("#landingImage").first.attribute("src").value.strip

  puts isbn
  puts price
  puts image

  save_result("Amazon", isbn, price, "EUR", url)
end
