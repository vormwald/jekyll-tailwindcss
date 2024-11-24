require "tailwindcss/ruby"

module Tailwindcss
  module Commands
    class << self
      def compile_command(debug: false, **kwargs)
        command = [
          Tailwindcss::Ruby.executable(**kwargs),
          "--input", "-",
          "--config", "./tailwind.config.js"
        ]

        command << "--minify" unless debug

        postcss_path = "postcss.config.js"
        command += ["--postcss", postcss_path] if File.exist?(postcss_path)

        command
      end
    end
  end
end
