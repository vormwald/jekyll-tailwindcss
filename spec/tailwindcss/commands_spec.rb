require "spec_helper"

RSpec.describe Tailwindcss::Commands do
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
end
