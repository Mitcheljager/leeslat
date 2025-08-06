require_relative "../config/environment"
require_relative "data/goodreads"

def get_book(isbn, attach_image: false)
  book = Book.find_or_initialize_by(isbn: isbn)

  return book unless book.new_record?

  data = get_goodreads_data(isbn) || {}

  if data[:is_ebook] || data[:title].blank?
    # Store that this book failed to fetch and may be skipped in future runs. Ebooks are always skipped
    # and as such are marked as permanent. Other books may be re-tried over time. A rake task will
    # periodically destroy entries that are not marked as permanent.
    SkippableISBN.create(isbn: isbn, permanent: data[:is_ebook] == true)

    raise "No title was returned for #{isbn}" if data[:title].blank?
    raise "Given book \"#{data[:title]}\" (#{isbn}) is an ebook" if data[:is_ebook]
  end

  # Some titles include a :, which (almost?) always mean it's a title followed by a subtitle
  main_title, subtitle = data[:title].split(":", 2).map(&:strip)

  book.title = main_title
  book.subtitle = subtitle if subtitle.present?
  book.language = data[:language]
  book.format = data[:format]
  book.published_date_text = data[:published_date] if data[:published_date]

  parse_genres_for_book(book, data[:genres]) if data[:genres].present?
  parse_authors_for_book(book, data[:authors]) if data[:authors].present?

  book.save!

  return book unless attach_image

  require_relative "attach_remote_image"

  attach_remote_image(book, data[:image_url])

  book.reload
end

def parse_authors_for_book(book, authors)
  authors.each do |author_name|
    # Remove anything in parenthesis "Name (Editor)", trim white space, and remove subsequent whitespace
    author_name = author_name.sub(/\s*\(.*\)\s*$/, "").strip.squeeze(" ")
    slug = author_name.parameterize

    author = Author.find_or_create_by!(slug: slug) do |author|
      author.name = author_name

      puts "Created author: #{author_name}"
    end

    book.authors << author unless book.authors.include?(author)
  end
end

def parse_genres_for_book(book, genre_names)
  genre_names.each do |genre_name|
    clean_genre = genre_name.strip.downcase

    genre = Genre.find_by("LOWER(name) = ?", clean_genre)

    # Try to find by keywords if not found by name
    if genre.nil?
      genre = Genre.all.find do |g|
        g.separated_keywords.map(&:downcase).include?(clean_genre)
      end
    end

    next unless genre
    next if book.genres.include?(genre)

    puts "Adding genre \"#{genre.name}\" to book \"#{book.title}\""

    book.genres << genre
  end
end

def find_listing_for_isbn_and_source_name(isbn, source_name)
  book = Book.find_by_isbn(isbn)
  book&.listings&.joins(:source)&.find_by(sources: { name: source_name })
end
