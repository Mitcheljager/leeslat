require_relative "../base"
require "nokogiri"

def scrape_amazon(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Amazon")

  base_path = "https://www.amazon.nl"
  url = clean_url(listing&.url || "")

  if url.blank?
    puts "Running Amazon for search page for #{isbn}"

    document = get_document("#{base_path}/s?k=#{isbn}")
    first_search_item_path = document.css("[role='listitem'] a").first.attribute("href").value
    url = clean_url(base_path + first_search_item_path).sub(/\/[^\/]*$/, "")
  end

  if url.blank?
    puts "No valid url was found on Amazon for #{isbn}"
  else
    if listing&.url
      puts "Using previous set url #{url}"
    else
      puts "Using newly fetched url #{url}"
    end

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

    { url: url, price: price }
  end
end

def clean_url(url)
  url.sub(/\/[^\/]*$/, "") # Remove referal bits after the final /
end
