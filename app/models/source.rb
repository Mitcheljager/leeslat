class Source < ApplicationRecord
  has_many :sources, dependent: :destroy

  validates :name, presence: true, uniqueness: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true, uniqueness: { case_sensitive: false }
  validates :base_url, presence: true, uniqueness: true

  def to_param
    slug
  end
end
