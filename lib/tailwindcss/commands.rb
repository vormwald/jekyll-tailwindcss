require "tailwindcss/ruby"
require "os"

module Tailwindcss
  module Commands
    class << self
      def compile_command(debug: false, config_path: nil, postcss_path: nil, **kwargs)
        executable = Tailwindcss::Ruby.executable(**kwargs).to_s

        command = [
          "#{(OS.windows? && executable.include?(" ")) ? "\"%s\"" : "%s"}" % executable,
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
