require "spec_helper"

RSpec.describe Tailwindcss::Commands do
  let(:executable) { instance_double(Tailwindcss::Ruby.executable) }
  before do
    allow(Tailwindcss::Ruby).to receive(:executable).and_return(executable)
  end

  describe ".compile_command" do
    it "receives arguments" do
      args = ["--input", "-", "--config", "./tailwind.config.js", "--minify"]

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
        allow(File).to receive(:exist?).with(postcss_path).and_return(true)

        command_args = described_class.compile_command
        expect(command_args).to include("--postcss")
        expect(command_args).to include(postcss_path)
      end
    end
  end
end
