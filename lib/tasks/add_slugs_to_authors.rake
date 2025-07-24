task add_slugs_to_authors: :environment do
  Author.all.each do |author|
    next if author.slug.present?

    author.update(slug: author.name.parameterize)
  end
end
