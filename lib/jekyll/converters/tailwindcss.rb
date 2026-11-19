module Jekyll
  module Converters
    class Tailwindcss < Converter
      safe true
      priority :low
      EXTENSION_PATTERN = %r{^\.tailwind(css)?$}i

      def matches(ext)
        EXTENSION_PATTERN.match? ext
      end

      def output_ext(ext)
        ".css"
      end

      def convert(content)
        unless ::Jekyll::Tailwindcss.v4?
          raise ::Jekyll::Tailwindcss::CompilationError, tailwind_v3_message
        end

        dev_mode = Jekyll.env == "development"
        Jekyll.logger.info "Jekyll Tailwind:", "Generating #{"minified " unless dev_mode}CSS"

        ::Jekyll::Tailwindcss::Commands.compile(tailwind_content, debug: dev_mode, chdir: @config["source"])
      end

      private

      def tailwind_content
        path = ::Jekyll::Tailwindcss.css_path(@config).gsub(/["\\]/) { |c| "\\#{c}" }
        "@import \"#{path}\";"
      end

      def tailwind_v3_message
        <<~MESSAGE.chomp
          You're using a .tailwindcss file extension, but your tailwindcss-ruby gem is below version 4.0.
          The .tailwindcss extension is only supported in v4.0.0 and above. Please either:
            - Upgrade with: bundle update tailwindcss-ruby
            - Stay on v3 with a .css file and tailwind.config.js, as described in the README's "Tailwind Version 3 Setup" section:
              https://github.com/vormwald/jekyll-tailwindcss#optional-choosing-a-specific-version-of-tailwindcss
        MESSAGE
      end
    end
  end
end
