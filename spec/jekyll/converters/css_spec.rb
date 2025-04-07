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
    let(:error_message) { nil }

    let(:jekyll_env) { "development" }
    let(:env_options) { {"BROWSERSLIST_IGNORE_OLD_DATA" => "1"} }
    let(:mock_stdin) { instance_double(IO).as_null_object }
    let(:mock_stdout) { instance_double(IO, read: css_content) }
    let(:mock_stderr) { instance_double(IO, read: error_message) }

    let(:compile_command_regex) { /.+\/tailwindcss --input -$/ }
    let(:compile_arguments) { ["--input", "-"] }

    before do
      allow(Jekyll).to receive(:env).and_return(jekyll_env)
      allow(Open3).to receive(:popen3).with(env_options, compile_command_regex).and_yield(mock_stdin, mock_stdout, mock_stderr, nil)
    end

    context "using defaults" do
      it "calls the tailwindcss CLI" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating CSS")
        expect(Jekyll.logger).not_to receive(:warn)
        expect(mock_stdin).to receive(:write).with(tailwindcss_content)
        expect(mock_stdout).to receive(:read)
        expect(mock_stderr).to receive(:read)

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
        expect(Jekyll.logger).not_to receive(:warn)
        expect(mock_stdin).to receive(:write).with(tailwindcss_content)
        expect(mock_stdout).to receive(:read)
        expect(mock_stderr).to receive(:read)

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
      let(:compile_command_regex) { /.+\/tailwindcss --input - --config tailwind.config.js$/ }
      let(:compile_arguments) { ["--input", "-", "--config", "./tailwind.config.js"] }

      it "calls the tailwindcss CLI" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating CSS")
        expect(Jekyll.logger).not_to receive(:warn)
        expect(mock_stdin).to receive(:write).with(tailwindcss_content)
        expect(mock_stdout).to receive(:read)
        expect(mock_stderr).to receive(:read)

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
        let(:compile_command_regex) { /.+\/tailwindcss --input - --config other_location$/ }
        let(:compile_arguments) { ["--input", "-", "--config", "./other_location"] }

        it "uses custom config location" do
          converter.instance_variable_set(:@config, {
            "tailwindcss" => {
              "config" => "other_location"
            }
          })

          converter.convert(tailwindcss_content)
        end
      end
    end

    context "when not in development mode" do
      let(:jekyll_env) { "production" }
      let(:compile_command_regex) { /--minify$/ }

      it "includes the --minify option" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Tailwind:", "Generating minified CSS")
        expect(converter.convert(tailwindcss_content)).to eq(css_content)
      end
    end

    context "when CLI returns an error" do
      let(:error_message) { "Unknown word at Input.error..." }

      it "logs the error, still returns output from stdout" do
        expect(Jekyll.logger).to receive(:warn).with("Jekyll Tailwind:", error_message)
        expect(mock_stdout).to receive(:read)
        expect(mock_stderr).to receive(:read)

        expect(converter.convert(tailwindcss_content)).to eq(css_content)
      end
    end
  end
end
