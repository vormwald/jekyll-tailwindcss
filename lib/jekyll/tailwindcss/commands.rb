# frozen_string_literal: true

require "open3"
require "tailwindcss/ruby"

module Jekyll
  module Tailwindcss
    module Commands
      # Without this ENV you'll get a warning about `Browserslist: caniuse-lite is outdated`
      # Since we're using the CLI, we can't update the data, so we ignore it.
      ENV_OPTIONS = {"BROWSERSLIST_IGNORE_OLD_DATA" => "1"}.freeze

      class << self
        def compile_command(debug: false, config_path: nil, postcss_path: nil, **kwargs)
          command = [
            ::Tailwindcss::Ruby.executable(**kwargs),
            "--input", "-"
          ]
          command += ["--config", config_path] if config_path
          command += ["--postcss", postcss_path] if postcss_path

          command << "--minify" unless debug

          command
        end

        # Runs the tailwindcss CLI against `content`, returning the compiled
        # CSS on success or nil (after logging) on failure.
        def compile(content, **kwargs)
          command = compile_command(**kwargs)
          stdout, stderr, status = Open3.capture3(ENV_OPTIONS, *command, stdin_data: content)

          unless status.success?
            Jekyll.logger.error "Jekyll Tailwind:", "tailwindcss CLI exited with status #{status.exitstatus}:\n#{stderr}"
            return nil
          end

          Jekyll.logger.warn "Jekyll Tailwind:", stderr unless stderr.empty?

          stdout
        end
      end
    end
  end
end
