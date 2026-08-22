# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jekyll::Converters::Css do
  subject(:converter) do
    described_class.new(Jekyll::Configuration::DEFAULTS.merge(plugin_config))
  end
  let(:plugin_config) { {} }

  it "has a version number" do
    expect(Jekyll::Tailwindcss::VERSION).not_to be nil
  end

  describe "#matches" do
    it "matches .css files" do
      expect(converter.matches(".css")).to be(true)
    end

    it "matches .CSS files because it is case insensitive" do
      expect(converter.matches(".CSS")).to be(true)
    end

    it "does not match non-.css files" do
      expect(converter.matches(".html")).to be(false)
    end
  end

  describe "#output_ext" do
    it "always returns the extention passed in" do
      expect(converter.output_ext(".CSS")).to eql(".CSS")
    end
  end

  describe "#convert" do
    let(:tailwindcss_content) do
      <<~TAILWINDCSS
        @import "tailwindcss";
      TAILWINDCSS
    end
    let(:css_content) { "body { color: red; }" }

    let(:jekyll_env) { "development" }

    before do
      allow(Jekyll).to receive(:env).and_return(jekyll_env)
      allow(Jekyll::Tailwindcss::Commands).to receive(:compile).and_return(css_content)
    end

    context "using defaults" do
      it "calls the tailwindcss CLI" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating CSS")
        expect(Jekyll::Tailwindcss::Commands).to receive(:compile)
          .with(tailwindcss_content, debug: true, config_path: nil, postcss_path: nil)
          .and_return(css_content)

        expect(converter.convert(tailwindcss_content)).to eq(css_content)
      end
    end

    context "When skipping preflight" do
      # https://tailwindcss.com/docs/preflight#disabling-preflight
      let(:tailwindcss_content) do
        <<~TAILWINDCSS
          @layer theme, base, components, utilities;
          @import "tailwindcss/theme.css" layer(theme);
          @import "tailwindcss/utilities.css" layer(utilities);
        TAILWINDCSS
      end

      it "calls the tailwind CLI" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating CSS")
        expect(Jekyll::Tailwindcss::Commands).to receive(:compile)
          .with(tailwindcss_content, debug: true, config_path: nil, postcss_path: nil)
          .and_return(css_content)

        expect(converter.convert(tailwindcss_content)).to eq(css_content)
      end
    end

    context "when using official plugins" do
      let(:tailwindcss_content) do
        # Example installation configuration for
        # https://github.com/tailwindlabs/tailwindcss-typography
        <<~TAILWINDCSS
          @import "tailwindcss";
          @plugin "@tailwindcss/typography";
        TAILWINDCSS
      end

      it "does not produce errors" do
        expect(Jekyll.logger).not_to receive(:error).with("Jekyll Tailwind:", /v3/)
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating CSS")

        converter.convert(tailwindcss_content)
      end
    end

    context "when using TailwindCSS v3" do
      let(:tailwindcss_content) do
        <<~TAILWINDCSS
          @tailwind base;
          @tailwind components;
          @tailwind utilities;
        TAILWINDCSS
      end
      let(:plugin_config) do
        {
          "tailwindcss" => {
            "config" => "tailwind.config.js"
          }
        }
      end

      it "calls the tailwindcss CLI" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating CSS")
        expect(Jekyll::Tailwindcss::Commands).to receive(:compile)
          .with(tailwindcss_content, debug: true, config_path: "tailwind.config.js", postcss_path: nil)
          .and_return(css_content)

        expect(converter.convert(tailwindcss_content)).to eq(css_content)
      end

      context "when no config path is specified" do
        let(:plugin_config) { {} }
        it "logs an error" do
          expect(Jekyll.logger).to receive(:error).with("Jekyll Tailwind:", "to use tailwind v3 you need to include a config path in _config.yml")
          converter.convert(tailwindcss_content)
        end
      end

      context "when custom config location is specified" do
        let(:plugin_config) do
          {
            "tailwindcss" => {
              "config" => "other_location"
            }
          }
        end

        it "uses custom config location" do
          expect(Jekyll::Tailwindcss::Commands).to receive(:compile)
            .with(tailwindcss_content, debug: true, config_path: "other_location", postcss_path: nil)
            .and_return(css_content)

          converter.convert(tailwindcss_content)
        end
      end
    end

    context "when not in development mode" do
      let(:jekyll_env) { "production" }

      it "includes the --minify option" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating minified CSS")
        expect(Jekyll::Tailwindcss::Commands).to receive(:compile)
          .with(tailwindcss_content, debug: false, config_path: nil, postcss_path: nil)
          .and_return(css_content)

        expect(converter.convert(tailwindcss_content)).to eq(css_content)
      end
    end

    context "when the CLI fails" do
      before do
        allow(Jekyll::Tailwindcss::Commands).to receive(:compile).and_return(nil)
      end

      it "returns nil so Jekyll does not write a bad file" do
        expect(converter.convert(tailwindcss_content)).to be_nil
      end
    end

    context "when compiling raises an unexpected error" do
      before do
        allow(Jekyll::Tailwindcss::Commands).to receive(:compile).and_raise(StandardError, "boom")
      end

      it "logs the error and returns nil so Jekyll does not write a bad file" do
        expect(Jekyll.logger).to receive(:error).with("Jekyll Tailwind:", "StandardError: boom")

        expect(converter.convert(tailwindcss_content)).to be_nil
      end
    end
  end
end
