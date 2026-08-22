# frozen_string_literal: true

require "spec_helper"
require "jekyll"
require "tmpdir"
require "fileutils"

RSpec.describe "building a Jekyll site with the real tailwindcss CLI" do
  let(:fixture_source) { File.expand_path("../fixtures/site", __dir__) }

  it "generates real tailwind-compiled CSS into _site" do
    Dir.mktmpdir do |tmp|
      # Build from a throwaway copy of the fixture: Jekyll writes its disk cache
      # (.jekyll-cache) under the site source, so building in place would leave
      # artifacts behind in the repository.
      source = File.join(tmp, "site")
      destination = File.join(tmp, "_site")
      FileUtils.cp_r(fixture_source, source)

      # The plugin resolves the tailwind css config path (default "./_tailwind.css")
      # relative to the process working directory rather than the site source,
      # so the site being built must be the cwd for the build to find it.
      Dir.chdir(source) do
        config = Jekyll.configuration(
          "source" => source,
          "destination" => destination,
          "quiet" => true
        )
        site = Jekyll::Site.new(config)
        site.process
      end

      generated_css_path = File.join(destination, "assets", "css", "styles.css")

      expect(File).to exist(generated_css_path)

      generated_css = File.read(generated_css_path)
      expect(generated_css).not_to be_empty
      expect(generated_css).to match(/text-center/)
    end
  end
end
