# frozen_string_literal: true

require "fileutils"

module Jekyll
  module Commands
    class Tailwind < Jekyll::Command
      TAILWIND_CSS_CONTENT = <<~CSS
        @import "tailwindcss";

        /* Add any custom CSS or additional imports here */
      CSS

      STYLES_TAILWINDCSS_CONTENT = <<~CSS
        ---
        ---
        This content is replaced by output from the tailwindcss CLI.
      CSS

      class << self
        def init_with_program(prog)
          prog.command(:"tailwindcss:install") do |c|
            c.syntax "tailwindcss:install"
            c.description "Create the files needed to use TailwindCSS in this Jekyll site"
            add_build_options(c)

            c.action do |_args, opts|
              Jekyll::Commands::Tailwind.process(opts)
            end
          end
        end

        def process(opts = {})
          config = configuration_from_options(opts)
          source = config["source"]

          create_file(File.join(source, "_tailwind.css"), TAILWIND_CSS_CONTENT)
          create_file(File.join(source, "assets", "css", "styles.tailwindcss"), STYLES_TAILWINDCSS_CONTENT)

          Jekyll.logger.info "Jekyll Tailwind:", "Next steps:"
          Jekyll.logger.info "Jekyll Tailwind:", '  Add <link rel="stylesheet" href="{{ \'/assets/css/styles.css\' | relative_url }}"> to your layout head'
          Jekyll.logger.info "Jekyll Tailwind:", "  Run `bundle exec jekyll serve`"
        end

        private

        def create_file(path, content)
          if File.exist?(path)
            Jekyll.logger.info "Jekyll Tailwind:", "Skipped #{path} (already exists)"
            return
          end

          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, content)
          Jekyll.logger.info "Jekyll Tailwind:", "Created #{path}"
        end
      end
    end
  end
end
