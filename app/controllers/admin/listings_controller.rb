class Admin::ListingsController < Admin::BaseController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]

  def index
    @listings = Listing.all.page(params[:page])
  end

  def show
  end

  def new
    @listing = Listing.new
  end

  def edit
  end

  def create
    @listing = Listing.new(listing_params)

    if @listing.save
      redirect_to [:admin, @listing], notice: "Listing was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @listing.update(listing_params)
      redirect_to [:admin, @listing], notice: "Listing was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    book = @listing.book

    @listing.destroy!
    redirect_to [:admin, book], notice: "Listing was successfully destroyed.", status: :see_other
  end

  private

  def set_listing
    @listing = Listing.find(params.expect(:id))
  end

  def listing_params
    params.expect(listing: [:book_id, :source_id, :price, :condition, :condition_details, :currency, :url, :last_scraped_at])
  end
end
