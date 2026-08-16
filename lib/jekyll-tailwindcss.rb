# frozen_string_literal: true

require "jekyll"
require_relative "jekyll-tailwindcss/version"
require_relative "jekyll/tailwindcss/commands"
require_relative "jekyll/commands/tailwind"
require_relative "jekyll/converters/css"
require_relative "jekyll/converters/tailwindcss"

module Jekyll
  module Tailwindcss
  end
end
