require "open3"

module Jekyll
  module Converters
    class Tailwind < Converter
      safe true
      priority :low
      EXTENSION_PATTERN = %r{^\.tailwind(css)?$}i

      def matches(ext)
        ext =~ EXTENSION_PATTERN
      end

      def output_ext(ext)
        ".css"
      end

      def convert(content)
        unless valid_tailwindcss_gem_version?
          print_tailwind_v3_warning and return content
        end

        dev_mode = Jekyll.env == "development"
        Jekyll.logger.info "Jekyll Tailwind:", "Generating #{dev_mode ? "" : "minified "}CSS"

        compile_command = ::Tailwindcss::Commands
          .compile_command(debug: dev_mode)
          .join(" ")

        output, error = nil
        Open3.popen3(tailwindcss_env_options, compile_command) do |stdin, stdout, stderr, _wait_thread|
          stdin.write tailwind_content
          stdin.close
          output = stdout.read
          error = stderr.read
        end
        Jekyll.logger.warn "Jekyll Tailwind:", error unless error.nil?

        output
      rescue => e
        Jekyll.logger.error "Jekyll Tailwind:", e.message
        content
      end

      private

      def tailwind_content
        "@import '#{tailwind_css_path}';"
      end

      def tailwindcss_env_options
        # Without this ENV you'll get a warning about `Browserslist: caniuse-lite is outdated`
        # Since we're using the CLI, we can't update the data, so we ignore it.
        {}
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

      def print_tailwind_v3_warning
        Jekyll.logger.warn "Jekyll Tailwind:", "You're using a .tailwindcss file extension but your tailwindcss-ruby gem is below version 4.0."
        Jekyll.logger.warn "Jekyll Tailwind:", "The .tailwindcss extension is only supported in v4.0.0 and above."
        Jekyll.logger.warn "Jekyll Tailwind:", "Please either:"
        Jekyll.logger.warn "Jekyll Tailwind:", "  - Upgrade with: bundle update tailwindcss-ruby"
        Jekyll.logger.warn "Jekyll Tailwind:", "  - Rename your file to use .css extension with @import \"tailwindcss\" syntax"
      end
    end
  end
end
