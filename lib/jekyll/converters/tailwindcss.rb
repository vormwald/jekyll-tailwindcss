require "open3"

module Jekyll
  module Converters
    class Tailwindcss < Converter
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
        return content unless /@tailwind|@import ['"]tailwindcss['"]/i.match?(content)
        if content.include?("@tailwind") && config_path.nil?
          Jekyll.logger.error "Jekyll Tailwind:", "to use tailwind v3 you need to include a config path in _config.yml"
          return content
        end

        dev_mode = Jekyll.env == "development"
        Jekyll.logger.info "Jekyll Tailwind:", "Generating #{dev_mode ? "" : "minified "}CSS"

        compile_command = ::Tailwindcss::Commands
          .compile_command(debug: dev_mode, config_path: config_path, postcss_path: postcss_path)
          .join(" ")

        output, error = nil
        Open3.popen3(tailwindcss_env_options, compile_command) do |stdin, stdout, stderr, _wait_thread|
          stdin.write content # write the content of *.tailwindcss to the tailwindcss CLI as input
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

      def tailwindcss_env_options
        # Without this ENV you'll get a warning about `Browserslist: caniuse-lite is outdated`
        # Since we're using the CLI, we can't update the data, so we ignore it.
        {"BROWSERSLIST_IGNORE_OLD_DATA" => "1"}
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
