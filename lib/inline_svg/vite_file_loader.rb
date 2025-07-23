# frozen_string_literal: true

# https://henrikbjorn.medium.com/til-how-to-use-the-inline-svg-gem-with-vite-ruby-rails-2b0c700b40ca

module InlineSvg
  class ViteFileLoader
    def self.named(filename)
      path = ViteRuby.instance.manifest.path_for(filename)

      return fetch_from_dev_server(path) if ViteRuby.instance.dev_server_running?

      Rails.public_path.join(path).read
    end

    def self.fetch_from_dev_server(path)
      config = ViteRuby.config

      path = "#{config.protocol}://#{config.host_with_port}#{path}"

      URI.open(path)
    end
  end
end
