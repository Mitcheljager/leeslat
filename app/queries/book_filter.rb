class BookFilter
  attr_reader :books, :params

  def initialize(books = Book.all, params = {})
    @books = books
    @params = params
  end

  def filter
    filter_by_condition
    filter_by_availability
    filter_by_year
    filter_by_genres
    sort
  end

  private

  def filter_by_condition
    return if params[:condition].blank?

    @books = books.joins(:listings).where(listings: { condition: params[:condition] })
  end

  def filter_by_availability
    return if params[:available].nil?

    available = ActiveModel::Type::Boolean.new.cast(params[:available])
    @books = books.joins(:listings).where(listings: { available: available }).where.not(listings: { price: 0 })
  end

  def filter_by_year
    return if params[:year].blank?

    year = params[:year].to_s.strip
    return unless year.match?(/^\d{4}$/)

    @books = books.where("published_date_text LIKE ?", "#{year}%")
  end

  def filter_by_genres
    return if params[:genres].blank?

    genre_ids = Genre.where(slug: Array(params[:genres])).pluck(:id)
    @books = books.joins(:genres).where(genres: { id: genre_ids })
  end

  def sort
    if params[:sort] == "new"
      @books = books.order(Arel.sql("published_date_text DESC"))
    elsif params[:sort] == "old"
      @books = books.order(Arel.sql("published_date_text ASC"))
    else
      @books = books.order(hotness: :desc)
    end
  end
end
