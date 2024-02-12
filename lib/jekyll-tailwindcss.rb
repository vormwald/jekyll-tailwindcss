# frozen_string_literal: true

require "jekyll"
require_relative "tailwindcss/version"
require_relative "jekyll/converters/tailwindcss"

module Jekyll
  module Tailwindcss
    class Error < StandardError; end
    # Your code goes here...
  end
end
