require_relative "../base"
require "nokogiri"

def scrape_boekennl(isbn, title)
  listing = find_listing_for_isbn_and_source_name(isbn, "Boeken.nl")

  slug = title.parameterize
  url = listing&.url || "https://boeken.nl/boeken/#{isbn}/#{slug}"

  puts "Running Boeken.nl for: " + url

  document = get_document(url)

  is_correct_document = document.include?("Beschrijving:")

  if !is_correct_document
    puts "Searching bing for #{isbn}..."

    search_document = get_document("https://www.bing.com/search?q=site%3Aboeken.nl+#{isbn}")
    url = search_document.css("h2 a").first.attribute("href")

    if url.include?("boeken.nl")
      puts "Re-running Boeken.nl for: " + url
      document = get_document(url)
    end
  end

  price = document.css(".product-info .uc-price").first.text.strip.gsub("€", "").gsub(",", ".")
  image = document.css(".group-cover-and-photos .field-name-field-cover img").first.attribute("data-src").value.strip
  description = document.css(".field-name-body .nxte-shave-expanding-item").first.text.strip
  number_of_pages = document.css(".field-name-field-page-count .field-item").first.text.strip

  puts price
  puts image
  puts description
  puts number_of_pages

  save_result("Boeken.nl", isbn, price, "EUR", url, description, number_of_pages)
end
