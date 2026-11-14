# frozen_string_literal: true

require "open3"
require "tailwindcss/ruby"

module Jekyll
  module Tailwindcss
    # Raised when Tailwind can't produce CSS. Jekyll re-raises converter
    # errors, so this fails `jekyll build` instead of publishing a broken
    # stylesheet.
    class CompilationError < StandardError; end

    module Commands
      # Without this ENV you'll get a warning about `Browserslist: caniuse-lite is outdated`
      # Since we're using the CLI, we can't update the data, so we ignore it.
      ENV_OPTIONS = {"BROWSERSLIST_IGNORE_OLD_DATA" => "1"}.freeze

      class << self
        def compile_command(debug: false, config_path: nil, postcss_path: nil, **kwargs)
          command = [
            executable(**kwargs),
            "--input", "-"
          ]
          command += ["--config", config_path] if config_path
          command += ["--postcss", postcss_path] if postcss_path

          command << "--minify" unless debug

          command
        end

        # Path to the platform-specific tailwindcss binary provided by the
        # tailwindcss-ruby gem. Raises CompilationError when it's missing,
        # most often because Gemfile.lock lacks the build machine's platform.
        def executable(**kwargs)
          ::Tailwindcss::Ruby.executable(**kwargs)
        rescue ::Tailwindcss::Ruby::UnsupportedPlatformException,
          ::Tailwindcss::Ruby::ExecutableNotFoundException,
          ::Tailwindcss::Ruby::DirectoryNotFoundException => e
          raise CompilationError, e.message
        end

        # Runs the tailwindcss CLI against `content` and returns the compiled
        # CSS. Raises CompilationError if the CLI can't be found or run, or if
        # it exits unsuccessfully.
        def compile(content, **kwargs)
          command = compile_command(**kwargs)
          stdout, stderr, status = run(command, content)

          unless status.success?
            raise CompilationError, "tailwindcss CLI exited with status #{status.exitstatus}:\n#{stderr}"
          end

          Jekyll.logger.warn "Jekyll Tailwind:", stderr unless stderr.empty?

          stdout
        end

        private

        def run(command, content)
          Open3.capture3(ENV_OPTIONS, *command, stdin_data: content)
        rescue SystemCallError => e
          raise CompilationError, "could not run the tailwindcss CLI (#{command.first}): #{e.message}"
        end
      end
    end
  end
end
