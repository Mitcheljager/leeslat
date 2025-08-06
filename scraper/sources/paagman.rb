require_relative "../get_document"

def scrape_paagman(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Paagman")

  url = listing&.url

  if listing&.url
    puts "Running previously fetched url For Paagman for: " + url

    document = get_document(url)
  else
    puts "Running new url for Paagman"

    # Paagman automatically redirects when searching for an isbn if that isbn exists
    url, document = get_document("https://www.paagman.nl/zoek?term=#{isbn}", return_url: true)

    # No search results were returned for this isbn
    if document.nil? || document.include?("geen resultaten")
      puts "No search results for #{isbn}"
      return { url: nil, available: false }
    end
  end

  description = document.at_css(".description-original-2")&.text&.strip
  number_of_pages = document.at_css("li:contains('Bladzijden:')")&.text&.gsub("Bladzijden:", "")&.strip
  price = document.at_css(".priceFor")&.text&.gsub("€", "")&.gsub(",", ".")&.strip
  available = document.text.include?("OP VOORRAAD")

  { url:, price:, description:, number_of_pages:, condition: :new, available: available }
end
