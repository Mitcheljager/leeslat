require_relative "../base"
require_relative "../helpers/log_time"

isbn_list = []
start_time = DateTime.now

# Bol.com - 30 entries per page, 100 pages, many subpaths
subpaths = [
  "thrillers-en-spannende-boeken/2551",
  "detectives/40637",
  "horror-en-bovennatuurlijke-thrillers/40414",
  "psychologische-thrillers/40643",
  "literatuur-romans-boek/24410",
  "geschiedenisboeken-boek/40347",
  "boeken-over-religie-spiritualiteit-filosofie-boek/2562",
  "boeken-over-wetenschap-en-natuur-boek/23952",
  "literaire-klassiekers/40491",
  "oorlogsromans/41285",
  "romanceboeken/40494",
  "streekromans/40498",
  "speculatieve-romans/40495"
]

subpaths.each do |subpath|
  # 8292 is English, 8293 is Dutch
  languages = ["8292", "8293"]
  languages.each do |language|
    for page in 1..10 do
      # + 11209 is the category for books, which means we exclude Ebooks and Audiobooks
      document = get_document("https://www.bol.com/nl/nl/l/#{subpath}/#{language}+11209/?page=#{page}")

      next if document.nil?

      document.css(".product-item__content").each do |node|
        next if node.include?("Ebook") # Specifically Ebook, not e-book, as that would include the other variant sections

        # Find any 13 digit code, presumably the ISBN
        match = node.to_s.match(/\b\d{13}\b/)
        next unless match.present?

        isbn_list << match[0]
      end
    end
  end
end

count = 0

# Process all indexed ISBNs, skipping any that are invalid
isbn_list.each do |isbn|
  count += 1
  skippable = SkippableISBN.find_by_isbn(isbn)

  # An ISBN has previously attempted to be indexed but failed. It could have failed because there was no Goodreads
  # entry, or because the book was an ebook.
  if skippable.present?
    puts "Skipped #{isbn}"
    next
  end

  puts "\e[44m #{count} out of #{isbn_list.count} \e[0m"

  begin
    book = get_book(isbn, attach_image: true)

    raise "No book was returned from get_book with isbn #{isbn}" if book.nil?
  rescue => error
    puts "Book with #{isbn} failed to be indexed from get_various_books.rb"
    puts error

    # Show full backtrace but skip for RuntimeErrors, as those would have been manually triggered "raise" errors,
    # which we can safely(?) ignore.
    puts error.backtrace.join("\n") if error.class.to_s != "RuntimeError"
  end

  # Wait 1 seconds to prevent hitting rate limits on the Google API, which is limited to 100 requests a minute.
  # It's also limited to 1000 per day, but that's another issue.
  # sleep 1
end

LogTime.log_end_time(start_time)
