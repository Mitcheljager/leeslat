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

  def attach_image_for_book
    begin
      output = `ruby #{Rails.root.join("scraper/attach_image_for_book.rb")} #{params[:isbn]}`
      Rails.logger.info output

      @book = Book.find_by_isbn(params[:isbn])
      throw unless @book.cover_image.attached?

      redirect_to @book, notice: "Image was successfully attached", status: :see_other
    rescue => error
      flash[:alert] = error
      redirect_to @book, status: :unprocessable_entity
    end
  end
end
