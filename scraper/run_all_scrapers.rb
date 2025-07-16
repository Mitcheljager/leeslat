require_relative "boeken"
require_relative "boekenbalie"
require_relative "amazon"

isbn = ARGV[0]
title = ARGV[1]

scrape_boekenbalie(isbn, title)
scrape_amazon(isbn)
