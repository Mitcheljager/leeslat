require_relative "../get_document"

def scrape_bol(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Bol.com")

  url = listing&.url

  if listing&.url
    puts "Running previously fetched url For Bol for: " + url

    document = get_document(url)
  else
    puts "Running new url for Bol"

    # Bol.com doesn't have nice enough urls to visit them directly via slug + isbn.
    # Instead, we search first and get first result
    base_url = "https://www.bol.com"
    document = get_document("#{base_url}/nl/nl/s/?searchtext=#{isbn}")

    # Sometimes pages display with a consent modal over top. When this happens the entire page markup
    # is completely different. Maybe some old version of their page that is shown behind the modal?
    link_element = document.at_css(".grid .flex.w-full a")
    link_element = document.at_css(".product-title") if link_element.blank?

    first_url = link_element&.attribute("href")&.value

    return { url: nil, available: false } if first_url.blank?

    # Get document again for url that was fetched from search
    url = base_url + first_url
    document = get_document(url)
  end

  # A link was found from search results, but for a different product entirely. Might be a fuzzy search match.
  return { url: nil, available: false } if document.nil? || !document&.at_css(".product-small-specs")&.text&.include?(isbn)

  description = document.at_css("[data-test='description']")&.text&.strip
  number_of_pages_label = document.at_css(".product-small-specs li:contains('pagina')")
  number_of_pages = number_of_pages_label&.text&.gsub("pagina's", "")&.strip

  # Only return listing for books actually sold by Bol.com, partners are handled separately.
  # Also skip books that are marked as "Niet leverbaar".
  available = document.at_css(".product-seller")&.text&.include?("Verkoop door bol") && !document.text.include?("Niet leverbaar")

  return { url:, available: false, description:, number_of_pages: } if !available

  # The price is shown in two separate elements with a pseudo element as the comma.
  # We get both elements separately and merge them together. Whole prices are shown with a "-".
  price_large = document.at_css(".price-block__price .promo-price").children.first.text.strip
  price_cents = document.at_css(".price-block__price .promo-price__fraction").text.strip.gsub("-", "00")
  price = "#{price_large}.#{price_cents}"

  price_includes_shipping = document.text.include?("Prijs inclusief verzendkosten")

  { url:, price:, description:, number_of_pages:, condition: :new, available:, price_includes_shipping: }
end
