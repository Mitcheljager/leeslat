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

    return { url: nil, available: false } if document&.text&.include?("Geen resultaten")

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

    return { url: nil, available: false } unless url.include?("/dp/")

    has_amazon_retour_deals = document.css("#merchant-info:contains('Amazon RetourDeals')")

    if has_amazon_retour_deals
      puts "Amazon page for \"#{isbn}\" does not contain RetourDeals offer"
      return { url: url, condition: :used, available: false }
    end

    price = document.css(".a-accordion-inner:contains('#{amazon_retourdeals_merchant_id}') form input[name*='amount']").first.get_attribute('value')

    { url:, price:, condition: :used, available: true }
  end
end

def clean_url(url)
  return url unless url.include?("?")
  url.sub(/\/ref=.*/, "") # Remove referal bits after the final ?
end
