require "tailwindcss/ruby"

module Tailwindcss
  module Commands
    class << self
      def compile_command(debug: false, config_path: nil, postcss_path: nil, **kwargs)
        command = [
          Tailwindcss::Ruby.executable(**kwargs),
          "--input", "-"
        ]
        command += ["--config", config_path] if config_path
        command += ["--postcss", postcss_path] if postcss_path

        command << "--minify" unless debug

        command
      end
    end
  end
end
