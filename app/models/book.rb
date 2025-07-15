class Book < ApplicationRecord
  self.primary_key = "isbn"

  validates :title, presence: true
  validates :author, presence: true
  validates :isbn, presence: true, uniqueness: true, format: { with: /\A[0-9]+\z/ }

  def to_param
    "#{title.parameterize}-#{isbn}"
  end
end
