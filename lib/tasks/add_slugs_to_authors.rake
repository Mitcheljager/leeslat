task add_slugs_to_authors: :environment do
  Author.where(slug: nil).each do |author|
    author.update!(slug: author.name.parameterize)
  end
end
