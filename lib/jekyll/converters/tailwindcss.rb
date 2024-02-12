module Jekyll
  module Converters
    class Tailwindcss< Converter
      safe true
      priority :low

      def matches(ext)
        ext =~ /^\.tailwindcss$/i
      end

      def output_ext(ext)
        ".css"
      end

      def convert(content)
        content
      end
    end
  end
end
