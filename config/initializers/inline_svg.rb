# frozen_string_literal: true
# https://henrikbjorn.medium.com/til-how-to-use-the-inline-svg-gem-with-vite-ruby-rails-2b0c700b40ca

require "inline_svg/vite_file_loader"

InlineSvg.configure do |config|
  config.asset_file = InlineSvg::ViteFileLoader
end
