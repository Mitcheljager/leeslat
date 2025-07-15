class Book < ApplicationRecord
  self.primary_key = "isbn"

  validates :title, presence: true
  validates :author, presence: true
  validates :isbn, presence: true, uniqueness: true

  def to_param
    isbn
  end
end
