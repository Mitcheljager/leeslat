class Genre < ApplicationRecord
  belongs_to :parent_genre, class_name: "Genre", optional: true
  has_many :subgenres, class_name: "Genre", foreign_key: "parent_genre_id", dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  def to_param
    slug
  end

  def separated_keywords
    keywords.to_s.split(",").map(&:strip)
  end
end
