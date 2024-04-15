module Jekyll
  module Converters
    class Tailwindcss < Converter
      safe true
      priority :low

      def matches(ext)
        /^\.tailwindcss$/i.match?(ext)
      end

      def output_ext(ext)
        ".css"
      end

      def convert(content)
        dev_mode = Jekyll.env == "development"
        Jekyll.logger.info "Jekyll Tailwind:", "Generating #{dev_mode ? "" : "minified "}CSS"

        compile_command = ::Tailwindcss::Commands.compile_command(debug: dev_mode).join(" ")

        `#{compile_command}`
      end
    end
  end
end
