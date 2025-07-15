class Book < ApplicationRecord
  self.primary_key = "isbn"

  def to_param
    isbn
  end
end
