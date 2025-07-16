class Source < ApplicationRecord
  has_many :sources, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :base_url, presence: true, uniqueness: true

  def to_param
    slug
  end
end
