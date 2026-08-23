# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jekyll::Converters::Tailwindcss do
  subject(:converter) do
    described_class.new(Jekyll::Configuration::DEFAULTS.merge(plugin_config))
  end
  let(:plugin_config) { {} }

  before do
    allow(Jekyll.logger).to receive(:info)
    allow(Jekyll.logger).to receive(:warn)
  end

  it "has a version number" do
    expect(Jekyll::Tailwindcss::VERSION).not_to be nil
  end

  describe "#matches" do
    it "matches .tailwind files" do
      expect(converter.matches(".tailwind")).to be(true)
    end

    it "matches .tailwindcss files" do
      expect(converter.matches(".tailwindcss")).to be(true)
    end

    it "does not match non-.css files" do
      expect(converter.matches(".html")).to be(false)
    end
  end

  describe "#output_ext" do
    it "always returns the extention passed in" do
      expect(converter.output_ext(".TailwindCSS")).to eql(".css")
    end
  end

  describe "#convert" do
    let(:css_path) { "./_tailwind.css" }
    let(:tailwind_input) { "@import '#{css_path}';" }
    let(:tailwind_output) { "body { color: red; }" }
    let(:ignored_content_input) { "This is ignored" }

    let(:jekyll_env) { "development" }

    before do
      allow(Jekyll).to receive(:env).and_return(jekyll_env)
      allow(Jekyll::Tailwindcss::CLI).to receive(:compile).and_return(tailwind_output)
    end

    context "using defaults" do
      it "calls the tailwindcss CLI" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating CSS")
        expect(Jekyll::Tailwindcss::CLI).to receive(:compile)
          .with(tailwind_input, debug: true)
          .and_return(tailwind_output)

        expect(converter.convert(ignored_content_input)).to eq(tailwind_output)
      end
    end

    context "when using a non-default tailwind.css location" do
      let(:plugin_config) do
        {
          "tailwindcss" => {
            "css_path" => "_data/other_tailwind_file.css"
          }
        }
      end
      let(:tailwind_input) { "@import '_data/other_tailwind_file.css';" }

      it "passes the config path to the tailwindcss CLI" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating CSS")
        expect(Jekyll::Tailwindcss::CLI).to receive(:compile)
          .with(tailwind_input, debug: true)
          .and_return(tailwind_output)

        expect(converter.convert(ignored_content_input)).to eq(tailwind_output)
      end
    end

    context "when using TailwindCSS v3" do
      let(:tailwindcss_ruby_version) { Gem::Version.new("3.4.1") }
      let(:tailwindcss_ruby_stub) do
        instance_double(Bundler::StubSpecification,
          version: tailwindcss_ruby_version)
      end

      before do
        allow(Gem).to receive(:loaded_specs)
          .and_return({"tailwindcss-ruby" => tailwindcss_ruby_stub})
      end

      it "calls prints a helpful message, does not convert" do
        expect(Jekyll.logger).to receive(:warn).with("Jekyll Tailwind:",
          "You're using a .tailwindcss file extension, but your tailwindcss-ruby gem is below version 4.0.")
        expect(Jekyll::Tailwindcss::CLI).not_to receive(:compile)

        expect(converter.convert(ignored_content_input)).to be_nil
      end
    end

    context "when not in development mode" do
      let(:jekyll_env) { "production" }

      it "includes the --minify option" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating minified CSS")
        expect(Jekyll::Tailwindcss::CLI).to receive(:compile)
          .with(tailwind_input, debug: false)
          .and_return(tailwind_output)

        expect(converter.convert(ignored_content_input)).to eq(tailwind_output)
      end
    end

    context "when the CLI fails" do
      before do
        allow(Jekyll::Tailwindcss::CLI).to receive(:compile).and_return(nil)
      end

      it "returns nil so Jekyll does not write the placeholder content" do
        expect(converter.convert(ignored_content_input)).to be_nil
      end
    end

    context "when compiling raises an unexpected error" do
      before do
        allow(Jekyll::Tailwindcss::CLI).to receive(:compile).and_raise(StandardError, "boom")
      end

      it "logs the error and returns nil instead of the placeholder content" do
        expect(Jekyll.logger).to receive(:error).with("Jekyll Tailwind:", "StandardError: boom")

        expect(converter.convert(ignored_content_input)).to be_nil
      end
    end
  end
end
