class SearchController < ApplicationController
  def index
    @books = Book.search(params[:query].strip)
  end

  # The search form is a post request, but to preserve nice urls we redirect the query to the
  # index above. A form with a get request would otherwise redirect itself to /zoeken?query={query},
  # which is valid, but not as nice looking a /zoeken/{query}.
  def post
    redirect_to search_path(params[:query].strip)
  end
end
