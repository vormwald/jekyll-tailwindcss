# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jekyll::Tailwindcss do
  describe ".css_path" do
    let(:config) { {"source" => "/srv/site"}.merge(plugin_config) }
    let(:plugin_config) { {} }

    it "defaults to _tailwind.css in the site source" do
      expect(described_class.css_path(config)).to eq("/srv/site/_tailwind.css")
    end

    context "with a relative tailwindcss.css_path" do
      let(:plugin_config) { {"tailwindcss" => {"css_path" => "./_data/tailwind.css"}} }

      it "resolves it against the site source, not the working directory" do
        expect(described_class.css_path(config)).to eq("/srv/site/_data/tailwind.css")
      end
    end

    context "with an absolute tailwindcss.css_path" do
      let(:plugin_config) { {"tailwindcss" => {"css_path" => "/elsewhere/tailwind.css"}} }

      it "keeps it" do
        expect(described_class.css_path(config)).to eq("/elsewhere/tailwind.css")
      end
    end
  end

  describe ".v4?" do
    def stub_version(version)
      spec = instance_double(Bundler::StubSpecification, version: Gem::Version.new(version))
      allow(Gem).to receive(:loaded_specs).and_return({"tailwindcss-ruby" => spec})
    end

    it "is true for tailwindcss-ruby 4.x" do
      stub_version("4.0.0")
      expect(described_class.v4?).to be(true)
    end

    it "is false for tailwindcss-ruby 3.x" do
      stub_version("3.4.19")
      expect(described_class.v4?).to be(false)
    end

    it "is false when tailwindcss-ruby isn't loaded" do
      allow(Gem).to receive(:loaded_specs).and_return({})
      expect(described_class.v4?).to be(false)
    end
  end
end
