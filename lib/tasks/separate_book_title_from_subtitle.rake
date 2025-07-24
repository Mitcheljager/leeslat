task separate_book_title_from_subtitle: :environment do
  Book.all.each do |book|
    next unless book.title.include?(":")

    main_title, subtitle = book.title.split(":", 2).map(&:strip)

    book.update(title: main_title, subtitle: subtitle)
  end
end
