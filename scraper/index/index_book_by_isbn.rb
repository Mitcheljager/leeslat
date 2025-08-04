require_relative "base"

isbn = ARGV[0]

begin
  if Book.find_by_isbn(isbn).present?
    puts "Book #{isbn} is already present"
    return
  end

  book = get_book(isbn, attach_image: true)
  puts "Successfully indexed book \"#{book.title}\" (#{book.isbn})"
rescue => error
  puts "Indexing of book #{isbn} was not successful"
  puts error
  puts error.backtrace.join("\n")
end
