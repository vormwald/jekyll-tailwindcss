# frozen_string_literal: true

require "jekyll"
require_relative "jekyll-tailwindcss/version"
require_relative "jekyll/tailwindcss/commands"
require_relative "jekyll/commands/tailwind"
require_relative "jekyll/converters/css"
require_relative "jekyll/converters/tailwindcss"

module Jekyll
  module Tailwindcss
    DEFAULT_CSS_PATH = "./_tailwind.css"

    class << self
      # Absolute path of the stylesheet that `.tailwindcss` files compile.
      # A relative `tailwindcss.css_path` is resolved against the site source,
      # not the working directory, so `jekyll build --source <dir>` works.
      def css_path(config)
        path = config.dig("tailwindcss", "css_path") || DEFAULT_CSS_PATH
        File.expand_path(path, config["source"])
      end

      # True when the loaded tailwindcss-ruby gem is 4.0 or newer.
      def v4?
        spec = Gem.loaded_specs["tailwindcss-ruby"]
        return false unless spec

        Gem::Version.new(spec.version) >= Gem::Version.new("4.0.0")
      rescue ArgumentError
        false
      end
    end
  end
end
