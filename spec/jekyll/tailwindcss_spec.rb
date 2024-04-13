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
end
