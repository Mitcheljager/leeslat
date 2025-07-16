require_relative "../base"
require "nokogiri"

def scrape_amazon(isbn)
  base_path = "https://www.amazon.nl"
  url = "#{base_path}/s?k=#{isbn}"

  document = get_document(url)

  puts "Running Amazon for: " + url

  is_ebook = document.at_css(".s-price-instructions-style")&.text.include?("Kindle")

  if is_ebook
    puts "Search price was listed as ebook, entering page instead"

    first_search_item_path = document.css("[role='listitem'] a").first.attribute("href").value
    document = get_document(base_path + first_search_item_path)

    price_text = document.at_css("#tmm-grid-swatch-PAPERBACK")&.text
    price = price_text.to_s.gsub(/[[:space:]]/, "").gsub("€", "").strip.gsub(",", ".").gsub("Paperback", "").strip

    if price.blank?
      price_text = document.at_css(".priceToPay span")&.text
      price = price_text.to_s.gsub("€", "").gsub(",", ".").strip
    end

    image = document.css("#landingImage").first.attribute("src").value.strip
  else
    price_text = document.at_css(".a-price .a-offscreen")&.text
    price = price_text.to_s.gsub(/[[:space:]]/, "").gsub("€", "").gsub(",", ".").strip

    image = document.css(".s-image").first.attribute("src").value.strip
  end

  puts isbn
  puts price
  puts image

  save_result("Amazon", isbn, price, "EUR", url)
end
