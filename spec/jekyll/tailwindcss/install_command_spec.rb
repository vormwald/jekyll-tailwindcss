# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "mercenary"

RSpec.describe Jekyll::Tailwindcss::InstallCommand do
  # Run each example inside a throwaway directory so relative paths in the
  # log output are predictable.
  around do |example|
    Dir.mktmpdir do |dir|
      @tmpdir = File.realpath(dir)
      Dir.chdir(@tmpdir) { example.run }
    end
  end

  let(:tailwind_css_path) { File.join(@tmpdir, "_tailwind.css") }
  let(:styles_path) { File.join(@tmpdir, "assets", "css", "styles.tailwindcss") }

  before do
    allow(Jekyll.logger).to receive(:info)
  end

  def install(opts = {})
    described_class.process({"source" => @tmpdir}.merge(opts))
  end

  describe ".process" do
    it "creates _tailwind.css and assets/css/styles.tailwindcss" do
      install

      expect(File.read(tailwind_css_path)).to include('@import "tailwindcss";')
      expect(File.read(styles_path)).to start_with("---\n---\n")
    end

    it "logs each created file relative to the working directory, then the next steps" do
      expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Created _tailwind.css").ordered
      expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Created assets/css/styles.tailwindcss").ordered
      expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Next steps:").ordered
      expect(Jekyll.logger).to receive(:info)
        .with("Jekyll Tailwind:", a_string_including(%(href="{{ '/assets/css/styles.css' | relative_url }}"))).ordered

      install
    end

    context "with a source directory below the working directory" do
      it "writes into the source and logs paths relative to the working directory" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Created src/_tailwind.css")
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Created src/assets/css/styles.tailwindcss")

        install("source" => "src")

        expect(File).to exist(File.join(@tmpdir, "src", "_tailwind.css"))
        expect(File).to exist(File.join(@tmpdir, "src", "assets", "css", "styles.tailwindcss"))
      end
    end

    context "when _config.yml sets tailwindcss.css_path" do
      before do
        File.write(File.join(@tmpdir, "_config.yml"), "tailwindcss:\n  css_path: ./_data/tailwind.css\n")
      end

      it "writes the import file there instead of _tailwind.css" do
        install

        expect(File.read(File.join(@tmpdir, "_data", "tailwind.css"))).to include('@import "tailwindcss";')
        expect(File).not_to exist(tailwind_css_path)
        expect(File).to exist(styles_path)
      end
    end

    context "when the files already exist" do
      before do
        FileUtils.mkdir_p(File.dirname(styles_path))
        File.write(tailwind_css_path, "custom content")
        File.write(styles_path, "custom content")
      end

      it "does not overwrite them" do
        install

        expect(File.read(tailwind_css_path)).to eq("custom content")
        expect(File.read(styles_path)).to eq("custom content")
      end

      it "logs a skipped message for each file and no next steps" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Skipped _tailwind.css (already exists)")
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Skipped assets/css/styles.tailwindcss (already exists)")
        expect(Jekyll.logger).not_to receive(:info).with("Jekyll Tailwind:", "Next steps:")

        install
      end
    end

    context "when tailwindcss-ruby is below 4.0" do
      before do
        allow(Jekyll::Tailwindcss).to receive(:v4?).and_return(false)
        allow(Jekyll.logger).to receive(:error)
      end

      it "exits non-zero without writing anything" do
        expect(Jekyll.logger).to receive(:error)
          .with("Jekyll Tailwind:", a_string_including("Nothing was written", "Tailwind Version 3", "#optional-choosing-a-specific-version-of-tailwindcss"))

        expect { install }.to raise_error(SystemExit) { |e| expect(e.status).not_to eq(0) }

        expect(Dir.children(@tmpdir)).to be_empty
      end
    end
  end

  describe ".init_with_program" do
    let(:program) { Mercenary::Program.new("jekyll") }
    let(:command) { program.commands[:"tailwindcss:install"] }

    before { described_class.init_with_program(program) }

    it "registers a tailwindcss:install command" do
      expect(command).not_to be_nil
    end

    it "only takes --source and --config" do
      expect(command.options.map(&:config_key)).to contain_exactly("source", "config")
    end
  end

  it "is discovered by Jekyll's command registry" do
    expect(Jekyll::Command.subclasses).to include(described_class)
  end
end
