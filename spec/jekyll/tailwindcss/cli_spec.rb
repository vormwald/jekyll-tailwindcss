require "spec_helper"

RSpec.describe Jekyll::Tailwindcss::CLI do
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
    let(:stdout) { "body { color: red; }" }
    let(:stderr) { "" }
    let(:exitstatus) { 0 }
    let(:status) { instance_double(Process::Status, success?: exitstatus.zero?, exitstatus: exitstatus) }
    let(:command) { described_class.compile_command }

    before do
      allow(Open3).to receive(:capture3)
        .with(described_class::ENV_OPTIONS, *command, stdin_data: content)
        .and_return([stdout, stderr, status])
    end

    it "runs the compiled command through Open3.capture3 and returns stdout" do
      expect(Jekyll.logger).not_to receive(:warn)
      expect(Jekyll.logger).not_to receive(:error)

      expect(described_class.compile(content)).to eq(stdout)
    end

    context "when the CLI writes to stderr but succeeds" do
      let(:stderr) { "Rebuilding..." }

      it "logs a single warning but still returns stdout" do
        expect(Jekyll.logger).to receive(:warn).with("Jekyll Tailwind:", stderr)

        expect(described_class.compile(content)).to eq(stdout)
      end
    end

    context "when the CLI exits with a nonzero status" do
      let(:exitstatus) { 1 }
      let(:stdout) { "" }
      let(:stderr) { "Unknown word at Input.error..." }

      it "logs the error and returns nil" do
        expect(Jekyll.logger).to receive(:error).with("Jekyll Tailwind:", a_string_including(stderr))
        expect(Jekyll.logger).not_to receive(:warn)

        expect(described_class.compile(content)).to be_nil
      end
    end
  end
end
