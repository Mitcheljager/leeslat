class ActionsController < ApplicationController
  def index_by_isbn
    begin
      output = `ruby #{Rails.root.join("scraper/index_book_by_isbn.rb")} #{params[:isbn]}`
      Rails.logger.info output

      @book = Book.find_by_isbn(params[:isbn])
      redirect_to @book, notice: "Book was successfully updated.", status: :see_other
    rescue => error
      flash[:alert] = error
      redirect_to root_path, status: :unprocessable_entity
    end
  end

  def attach_image_for_isbn
    @book = Book.find_by_isbn!(params[:isbn])

    begin
      output = `ruby #{Rails.root.join("scraper/attach_image_for_book.rb")} #{@book.isbn}`
      Rails.logger.info output

      raise "No image was attached" unless @book.cover_image.attached?

      redirect_to @book, notice: "Image was successfully attached", status: :see_other
    rescue => error
      flash[:alert] = error
      redirect_to @book, status: :unprocessable_entity
    end
  end

  def run_all_scrapers_for_isbn
    @book = Book.find_by_isbn!(params[:isbn])

    begin
      output = `ruby #{Rails.root.join("scraper/run_all_scrapers.rb")} isbn=#{@book.isbn} title="#{@book.title}"`
      Rails.logger.info output

      redirect_to @book, notice: "Scrapers completed successfully", status: :see_other
    rescue => error
      flash[:alert] = error
      redirect_to @book, status: :unprocessable_entity
    end
  end

  def generate_ai_keywords_for_isbn
    @book = Book.find_by_isbn!(params[:isbn])

    begin
      output = `ruby #{Rails.root.join("scraper/ai/openai_keywords.rb")} #{@book.isbn}`
      Rails.logger.info output

      redirect_to @book, notice: "Scrapers completed successfully", status: :see_other
    rescue => error
      flash[:alert] = error
      redirect_to @book, status: :unprocessable_entity
    end
  end
end
