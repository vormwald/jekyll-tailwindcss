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
        unless valid_tailwindcss_gem_version?
          raise ::Jekyll::Tailwindcss::CompilationError, tailwind_v3_message
        end

        dev_mode = Jekyll.env == "development"
        Jekyll.logger.info "Jekyll Tailwind:", "Generating #{"minified " unless dev_mode}CSS"

        ::Jekyll::Tailwindcss::Commands.compile(tailwind_content, debug: dev_mode)
      end

      private

      def tailwind_content
        "@import '#{tailwind_css_path}';"
      end

      def tailwind_css_path
        @config.dig("tailwindcss", "css_path") || "./_tailwind.css"
      end

      def valid_tailwindcss_gem_version?
        gem_spec = Gem.loaded_specs["tailwindcss-ruby"]
        return false unless gem_spec

        Gem::Version.new(gem_spec.version) >= Gem::Version.new("4.0.0")
      rescue
        # If anything goes wrong (gem not found, version format issues, etc.)
        false
      end

      def tailwind_v3_message
        <<~MESSAGE.chomp
          You're using a .tailwindcss file extension, but your tailwindcss-ruby gem is below version 4.0.
          The .tailwindcss extension is only supported in v4.0.0 and above. Please either:
            - Upgrade with: bundle update tailwindcss-ruby
            - Rename your file to use .css extension with @import "tailwindcss" syntax
        MESSAGE
      end
    end
  end
end
