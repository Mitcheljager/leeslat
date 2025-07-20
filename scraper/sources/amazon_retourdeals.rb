require_relative "../base"
require "nokogiri"

def scrape_amazon_retourdeals(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Amazon RetourDeals")
  amazon_retourdeals_merchant_id = "A3C1D9TG1HJ66Y"

  base_path = "https://www.amazon.nl"
  url = clean_url(listing&.url || "")

  if url.blank?
    puts "Running Amazon RetourDeals search page for #{isbn}"

    document = get_document("#{base_path}/s?k=#{isbn}")
    first_search_item_path = document.css("[role='listitem'] a").first.attribute("href").value
    url = clean_url(base_path + first_search_item_path)
  end

  if url.blank?
    puts "No valid url was found on Amazon RetourDeals for #{isbn}"
  else
    if listing&.url
      puts "Using previous set url #{url}"
    else
      puts "Using newly fetched url #{url}"
    end

    document = get_document(url)

    has_amazon_retour_deals = document.css("#merchant-info:contains('Amazon RetourDeals')")

    raise "Amazon page for \"#{isbn}\" does not contain RetourDeals offer" if document.include?("Amazon RetourDeals")

    price = document.css(".a-accordion-inner:contains('#{amazon_retourdeals_merchant_id}') form input[name*='amount']").first.get_attribute('value')

    number_of_pages_label = document.css("#detailBullets_feature_div .a-list-item span:contains('pagina')").first
    number_of_pages = number_of_pages_label&.text&.gsub("pagina's", "")&.strip

    description = document.css("#bookDescription_feature_div .a-expander-content").first.text.strip

    puts isbn
    puts price
    puts description
    puts number_of_pages

    { url: url, price: price, description: description, number_of_pages: number_of_pages }
  end
end

def clean_url(url)
  return url unless url.include?("?")
  url.sub(/\/ref=.*/, "") # Remove referal bits after the final ?
end
