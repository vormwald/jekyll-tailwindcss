# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "mercenary"

RSpec.describe Jekyll::Commands::Tailwind do
  around do |example|
    Dir.mktmpdir do |dir|
      @tmpdir = dir
      example.run
    end
  end

  let(:tailwind_css_path) { File.join(@tmpdir, "_tailwind.css") }
  let(:styles_path) { File.join(@tmpdir, "assets", "css", "styles.tailwindcss") }

  before do
    allow(Jekyll.logger).to receive(:info)
  end

  describe ".process" do
    it "creates _tailwind.css and assets/css/styles.tailwindcss" do
      described_class.process("source" => @tmpdir)

      expect(File.exist?(tailwind_css_path)).to be(true)
      expect(File.read(tailwind_css_path)).to include('@import "tailwindcss";')

      expect(File.exist?(styles_path)).to be(true)
      expect(File.read(styles_path)).to start_with("---\n---\n")
    end

    it "logs a created message for each file" do
      expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Created #{tailwind_css_path}")
      expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Created #{styles_path}")

      described_class.process("source" => @tmpdir)
    end

    context "when the files already exist" do
      before do
        FileUtils.mkdir_p(File.dirname(styles_path))
        File.write(tailwind_css_path, "custom content")
        File.write(styles_path, "custom content")
      end

      it "does not overwrite existing files" do
        described_class.process("source" => @tmpdir)

        expect(File.read(tailwind_css_path)).to eq("custom content")
        expect(File.read(styles_path)).to eq("custom content")
      end

      it "logs a skipped message for each file" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Skipped #{tailwind_css_path} (already exists)")
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Skipped #{styles_path} (already exists)")

        described_class.process("source" => @tmpdir)
      end
    end
  end

  describe ".init_with_program" do
    it "registers a tailwindcss:install command" do
      program = Mercenary::Program.new("jekyll")

      described_class.init_with_program(program)

      expect(program.commands[:"tailwindcss:install"]).not_to be_nil
    end
  end
end
