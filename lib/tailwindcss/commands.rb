require "tailwindcss/ruby"

module Tailwindcss
  module Commands
    class << self
      def compile_command(debug: false, config: nil, **kwargs)
        command = [
          Tailwindcss::Ruby.executable(**kwargs),
          "--input", "-"
        ]
        command += ["--config", config] if config

        command << "--minify" unless debug

        postcss_path = "postcss.config.js"
        command += ["--postcss", postcss_path] if File.exist?(postcss_path)

        command
      end
    end
  end
end
