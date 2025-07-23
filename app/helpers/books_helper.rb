module BooksHelper
  def book_listings_to_summary(book)
    return "\"#{@book.title}\" is helaas op het moment nergens beschikbaar. Het kan zijn dat wij het nog aan het indexeren zijn." if book.listings_with_price.empty?

    sorted = book.listings_with_price.sort_by(&:price)
    cheapest_listing = sorted.first
    cheapest_price = cheapest_listing.price_label
    cheapest_source = cheapest_listing.source.name

    # Boek, door auteurs, is het allergoedkoopst bij Verkoper, voor maar €12.34.
    # Optional if cheapest condition is known: Dit boek wordt als conditie verkocht
    # Optional if cheapest is not new condition: Daarnaast is het ook nieuw te vinden bij Verkoper voor €12.34.
    # Optional if more listings are given: Ook is het te vinden bij Verkoper voor €12.34.
    first_sentence = <<~HTML.strip
      #{book.title}, door #{human_list(book.authors.pluck(:name))}, is het allergoedkoopst bij #{cheapest_source}, voor maar #{cheapest_price}. #{listing_condition_sentence(cheapest_listing)} #{new_listings_note(sorted, cheapest_listing)}
    HTML

    other_listings = sorted.reject { |l| l == cheapest_listing }

    if other_listings.any?
      other_sentence = "Ook is het te vinden bij " +
        other_listings.map do |listing|
          price = listing.price_label
          "#{listing.source.name} voor #{price}#{listing.unknown_condition? ? "" : " (#{listing.condition_label})"}"
        end.to_sentence + "."
    else
      other_sentence = ""
    end

    first_sentence + "\n\n" + other_sentence.gsub(", and ", " en ") # Cheapo i18n
  end

  private

  # The second sentence, explaining the conditions. Can be empty if no condition is known.
  # Sentence should start with a space.
  def listing_condition_sentence(listing)
    return "" if listing.unknown_condition?
    " Dit boek wordt als #{listing.condition_label.downcase} verkocht."
  end

  # Return a sentence as a "new" alternative to a second hand book
  def new_listings_note(listings, cheapest_listing)
    return "" if cheapest_listing.new_condition?

    new_listings = listings.select { |l| l.new_condition? && l != cheapest_listing }

    return "" if new_listings.empty?

    listing = new_listings.first
    source = listing.source.name
    price = listing.price_label

    "Daarnaast is het ook nieuw te vinden bij #{source} voor #{price} euro."
  end
end
