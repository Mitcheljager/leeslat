require_relative "../base"
require_relative "../helpers/log_time"

GC.enable

isbn_list = []
start_time = DateTime.now

# Bol.com - 30 entries per page, 100 pages, many subpaths
subpaths = [
  "thrillers-en-spannende-boeken/2551"
]

subpaths.each do |subpath|
  # 8292 is English, 8293 is Dutch
  languages = ["8292", "8293"]
  languages.each do |language|
    puts language
    for page in 1..2 do
      # + 11209 is the category for books, which means we exclude Ebooks and Audiobooks
      document = get_document("https://www.bol.com/nl/nl/l/#{subpath}/#{language}+11209/?page=#{page}")

      next if document.nil?

      document.css(".product-item__content, #mainContent .flex-row .grid .min-w-none").each do |node|
        next if node.include?("Ebook") # Specifically Ebook, not e-book, as that would include the other variant sections

        puts node

        # Find any 13 digit code, presumably the ISBN
        match = node.to_s.match(/\b\d{13}\b/)
        puts match
        next unless match.present?

        isbn_list << match[0]
      end

      # Set document to nil so we garbage collect it later
      document = nil
    end
  end

  puts "Garbage collection..."
  GC.start
end

# An ISBN has previously attempted to be indexed but failed. It could have failed because there was no Goodreads
# entry, or because the book was an ebook.
isbn_list.reject! { |isbn| SkippableISBN.exists?(isbn: isbn) }

# Process all indexed ISBNs, skipping any that are invalid
isbn_list.each_with_index do |isbn, index|
  puts "\e[44m #{index} out of #{isbn_list.count} \e[0m"

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

  # Reset book and run Garbage collector for every 20 indexes
  book = nil

  if index % 20 == 0
    puts "Garbage collection..."
    GC.start
  end
end

LogTime.log_end_time(start_time)
