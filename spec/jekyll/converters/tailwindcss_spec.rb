# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jekyll::Converters::Tailwindcss do
  let(:converter) { described_class.new }

  it "has a version number" do
    expect(Jekyll::Tailwindcss::VERSION).not_to be nil
  end

  describe "#matches" do
    it "matches .tailwindcss files" do
      expect(converter.matches(".tailwindcss")).to be(true)
    end

    it "does not match non-.tailwindcss files" do
      expect(converter.matches(".html")).to be(false)
    end
  end

  describe "#output_ext" do
    it "always outputs the .css file extension" do
      expect(converter.output_ext("some-random-string")).to eql(".css")
    end
  end

  describe "#convert" do
    let(:content) { "this would be the content of styles.tailwindcss" }
    let(:jekyll_env) { "development" }
    before do
      allow(Jekyll).to receive(:env).and_return(jekyll_env)
    end

    context "using defaults" do
      it "calls the tailwindcss CLI" do
        expected_args = "-i ./_input.css -c ./tailwind.config.js"

        expect(converter).to receive(:`).with(/.+\/tailwindcss #{expected_args}$/)
        converter.convert(content)
      end
    end

    context "when not in development mode" do
      let(:jekyll_env) { "production" }
      it "includes the --minify option" do
        expect(converter).to receive(:`).with(/--minify$/)
        converter.convert(content)
      end
    end
  end
end
