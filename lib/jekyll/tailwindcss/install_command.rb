# frozen_string_literal: true

require "fileutils"
require "pathname"

module Jekyll
  module Tailwindcss
    # `jekyll tailwindcss:install`. Jekyll registers every Jekyll::Command
    # subclass, so the command shows up once the gem is loaded from the
    # :jekyll_plugins Gemfile group.
    class InstallCommand < Jekyll::Command
      TAILWIND_CSS_CONTENT = <<~CSS
        @import "tailwindcss";

        /* Add any custom CSS or additional imports here */
      CSS

      STYLES_TAILWINDCSS_PATH = File.join("assets", "css", "styles.tailwindcss")

      STYLES_TAILWINDCSS_CONTENT = <<~CSS
        ---
        ---
        This content is replaced by output from the tailwindcss CLI.
      CSS

      LINK_TAG = %(<link rel="stylesheet" href="{{ '/assets/css/styles.css' | relative_url }}">)

      V3_MESSAGE = <<~MESSAGE.chomp
        tailwindcss:install sets up Tailwind v4, but your tailwindcss-ruby gem is below 4.0. Nothing was written.
        Upgrade with `bundle update tailwindcss-ruby`, or set up v3 by hand as described in the README's "Tailwind Version 3 Setup" section:
        https://github.com/vormwald/jekyll-tailwindcss#optional-choosing-a-specific-version-of-tailwindcss
      MESSAGE

      class << self
        def init_with_program(prog)
          prog.command(:"tailwindcss:install") do |c|
            c.syntax "tailwindcss:install [options]"
            c.description "Create the files needed to use Tailwind CSS v4 in this Jekyll site"
            c.option "source", "-s", "--source SOURCE", "Custom source directory"
            c.option "config", "--config CONFIG_FILE[,CONFIG_FILE2,...]", Array, "Custom configuration file"

            c.action do |_args, opts|
              process(opts)
            end
          end
        end

        def process(opts = {})
          Jekyll.logger.abort_with "Jekyll Tailwind:", V3_MESSAGE unless Jekyll::Tailwindcss.v4?

          config = configuration_from_options(opts)
          created = [
            create_file(Jekyll::Tailwindcss.css_path(config), TAILWIND_CSS_CONTENT),
            create_file(File.join(config["source"], STYLES_TAILWINDCSS_PATH), STYLES_TAILWINDCSS_CONTENT)
          ].any?
          return unless created

          Jekyll.logger.info "Jekyll Tailwind:", "Next steps:"
          Jekyll.logger.info "Jekyll Tailwind:", "  Add #{LINK_TAG} to your layout's <head>"
          Jekyll.logger.info "Jekyll Tailwind:", "  Run `bundle exec jekyll serve`"
        end

        private

        # Writes `content` to `path` unless it exists. Returns true if it
        # created the file.
        def create_file(path, content)
          if File.exist?(path)
            Jekyll.logger.info "Jekyll Tailwind:", "Skipped #{display_path(path)} (already exists)"
            return false
          end

          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, content)
          Jekyll.logger.info "Jekyll Tailwind:", "Created #{display_path(path)}"
          true
        end

        # `path` relative to the working directory when it's inside it,
        # otherwise absolute.
        def display_path(path)
          relative = Pathname.new(path).relative_path_from(Pathname.pwd).to_s
          relative.start_with?("..") ? path : relative
        rescue ArgumentError
          path
        end
      end
    end
  end
end
