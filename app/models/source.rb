class Source < ApplicationRecord
  self.primary_key = "slug"

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :base_url, presence: true, uniqueness: true

  def to_param
    slug
  end
end
