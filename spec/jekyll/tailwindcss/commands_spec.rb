require "spec_helper"

RSpec.describe Jekyll::Tailwindcss::Commands do
  let(:executable) { instance_double(Tailwindcss::Ruby.executable) }
  before do
    allow(Tailwindcss::Ruby).to receive(:executable).and_return(executable)
  end

  describe ".compile_command" do
    it "receives arguments" do
      args = ["--input", "-", "--minify"]

      command_args = described_class.compile_command.slice(1...)
      expect(command_args).to eq(args)
    end

    context "when debug is true" do
      it "excludes --minify" do
        expect(described_class.compile_command(debug: true)).not_to include("--minify")
      end
    end

    context "when postcss.config.js exists" do
      it "includes postcss configuration" do
        postcss_path = "postcss.config.js"

        command_args = described_class.compile_command(postcss_path: postcss_path)
        expect(command_args).to include("--postcss")
        expect(command_args).to include(postcss_path)
      end
    end

    context "when config is passed" do
      it "includes config param with the passed value" do
        expect(described_class.compile_command(config_path: "other.config.js"))
          .to include("--config", "other.config.js")
      end
    end
  end

  describe ".compile" do
    let(:content) { "@import 'tailwindcss';" }
    let(:stdout) { +"body { color: red; }" }
    let(:stderr) { +"" }
    let(:exitstatus) { 0 }
    let(:status) { instance_double(Process::Status, success?: exitstatus.zero?, exitstatus: exitstatus) }
    let(:command) { described_class.compile_command }

    before do
      allow(Open3).to receive(:capture3)
        .with(described_class::ENV_OPTIONS, *command, stdin_data: content, binmode: true)
        .and_return([stdout, stderr, status])
    end

    it "runs the compiled command through Open3.capture3 and returns stdout" do
      expect(Jekyll.logger).not_to receive(:warn)
      expect(Jekyll.logger).not_to receive(:error)

      expect(described_class.compile(content)).to eq(stdout)
    end

    context "when the CLI writes to stderr but succeeds" do
      let(:stderr) { +"Rebuilding..." }

      it "logs a single warning but still returns stdout" do
        expect(Jekyll.logger).to receive(:warn).with("Jekyll Tailwind:", stderr)

        expect(described_class.compile(content)).to eq(stdout)
      end
    end

    context "when the CLI output contains non-ASCII characters" do
      # binmode: true makes Open3 return raw bytes
      let(:stdout) { "a::before { content: \"\u2014\"; }".b }
      let(:stderr) { "\u2248 tailwindcss v4.0.6\n\nDone in 25ms\n".b }

      it "tags stdout and stderr as UTF-8" do
        expect(Jekyll.logger).to receive(:warn)
          .with("Jekyll Tailwind:", satisfy { |s| s.encoding == Encoding::UTF_8 && s.valid_encoding? })

        result = described_class.compile(content)

        expect(result.encoding).to eq(Encoding::UTF_8)
        expect(result).to be_valid_encoding
        expect(result).to include("\u2014")
      end
    end

    context "when chdir is given" do
      it "runs the CLI in that directory" do
        expect(Open3).to receive(:capture3)
          .with(described_class::ENV_OPTIONS, *command, stdin_data: content, binmode: true, chdir: "/srv/site")
          .and_return([stdout, stderr, status])

        expect(described_class.compile(content, chdir: "/srv/site")).to eq(stdout)
      end
    end

    context "when the CLI exits with a nonzero status" do
      let(:exitstatus) { 1 }
      let(:stdout) { +"" }
      let(:stderr) { +"Unknown word at Input.error..." }

      it "raises CompilationError with the CLI's stderr" do
        expect(Jekyll.logger).not_to receive(:warn)

        expect { described_class.compile(content) }
          .to raise_error(Jekyll::Tailwindcss::CompilationError, /exited with status 1:\n#{Regexp.escape(stderr)}/)
      end
    end

    context "when the CLI can't be run" do
      before do
        allow(Open3).to receive(:capture3).and_raise(Errno::EACCES, "tailwindcss")
      end

      it "raises CompilationError" do
        expect { described_class.compile(content) }
          .to raise_error(Jekyll::Tailwindcss::CompilationError, /could not run the tailwindcss CLI/)
      end
    end

    context "when there's no tailwindcss binary for this platform" do
      before do
        allow(Tailwindcss::Ruby).to receive(:executable)
          .and_raise(Tailwindcss::Ruby::ExecutableNotFoundException, "Cannot find the tailwindcss executable for x86_64-linux")
      end

      it "raises CompilationError with tailwindcss-ruby's guidance" do
        expect { described_class.compile(content) }
          .to raise_error(Jekyll::Tailwindcss::CompilationError, /Cannot find the tailwindcss executable for x86_64-linux/)
      end
    end
  end
end
