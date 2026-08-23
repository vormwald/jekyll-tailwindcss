module Jekyll
  module Converters
    class Css < Converter
      safe true
      priority :low

      def matches(ext)
        /^\.css$/i.match?(ext)
      end

      def output_ext(ext)
        # At this point, we will have a CSS file
        ext
      end

      def convert(content)
        return content unless /@tailwind|@import ['"]tailwindcss/i.match?(content)
        if config_path.nil? && tailwind_v3_syntax?(content)
          Jekyll.logger.error "Jekyll Tailwind:", "to use tailwind v3 you need to include a config path in _config.yml"
          return content
        end

        dev_mode = Jekyll.env == "development"
        Jekyll.logger.info "Jekyll Tailwind:", "Generating #{"minified " unless dev_mode}CSS"

        ::Jekyll::Tailwindcss::CLI.compile(content, debug: dev_mode, config_path: config_path, postcss_path: postcss_path)
      rescue => e
        Jekyll.logger.error "Jekyll Tailwind:", "#{e.class}: #{e.message}"
        nil
      end

      private

      def tailwind_v3_syntax?(content)
        return false if content.include?("@plugin")

        content.include?("@tailwind")
      end

      def config_path
        @config.dig("tailwindcss", "config")
      end

      def postcss_path
        @config.dig("tailwindcss", "postcss")
      end
    end
  end
end
