require_relative "base"
require "nokogiri"

def scrape_boekenbalie(isbn, title)
  slug = title.parameterize
  url = "https://boekenbalie.nl/#{slug}/#{isbn}"

  puts "Running Boekenbalie for: " + url

  document = get_document(url)

  price = document.css(".product-detail-price").first.text.strip.gsub(",", ".")
  image = document.css(".product-detail-media-gallery img").first.attribute("src").value.strip

  puts title
  puts isbn
  puts price
  puts image

  save_result("Boekenbalie", isbn, price, "EUR", url)
end
