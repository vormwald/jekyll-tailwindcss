# frozen_string_literal: true

require "spec_helper"
require "jekyll"
require "tmpdir"
require "fileutils"

RSpec.describe "building a Jekyll site with the real tailwindcss CLI" do
  let(:fixture_source) { File.expand_path("../fixtures/site", __dir__) }

  # Builds a throwaway copy of the fixture site and returns the generated CSS.
  # The block, if given, can modify the copied source before the build.
  def build_site(quiet: true)
    Dir.mktmpdir do |tmp|
      # Build from a throwaway copy of the fixture: Jekyll writes its disk cache
      # (.jekyll-cache) under the site source, so building in place would leave
      # artifacts behind in the repository.
      source = File.join(tmp, "site")
      destination = File.join(tmp, "_site")
      FileUtils.cp_r(fixture_source, source)
      yield source if block_given?

      # The plugin resolves the tailwind css config path (default "./_tailwind.css")
      # relative to the process working directory rather than the site source,
      # so the site being built must be the cwd for the build to find it.
      Dir.chdir(source) do
        config = Jekyll.configuration(
          "source" => source,
          "destination" => destination,
          "quiet" => quiet
        )
        site = Jekyll::Site.new(config)
        site.process
      end

      generated_css_path = File.join(destination, "assets", "css", "styles.css")

      expect(File).to exist(generated_css_path)

      File.read(generated_css_path, encoding: Encoding::UTF_8)
    end
  end

  it "generates real tailwind-compiled CSS into _site" do
    generated_css = build_site

    expect(generated_css).not_to be_empty
    expect(generated_css).to match(/text-center/)
  end

  context "when the locale is not UTF-8" do
    # Under LANG=C (common on minimal CI images) Ruby's default external
    # encoding is US-ASCII. Simulate that for the duration of the example.
    around do |example|
      original_encoding = Encoding.default_external
      original_log_level = Jekyll.logger.level
      with_warnings_silenced { Encoding.default_external = Encoding::US_ASCII }
      example.run
    ensure
      with_warnings_silenced { Encoding.default_external = original_encoding }
      Jekyll.logger.log_level = original_log_level
    end

    def with_warnings_silenced
      verbose = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = verbose
    end

    it "still compiles CSS containing non-ASCII characters" do
      # Build at normal verbosity so the CLI's stderr ("≈ tailwindcss ...") is
      # actually formatted by Jekyll's logger, but keep it out of the spec output.
      allow(Jekyll.logger.writer).to receive(:info)
      allow(Jekyll.logger.writer).to receive(:warn)
      Jekyll.logger.log_level = :info
      expect(Jekyll.logger).not_to receive(:error)

      generated_css = build_site(quiet: false) do |source|
        File.write(File.join(source, "_tailwind.css"), <<~CSS, encoding: Encoding::UTF_8)
          /* Site styles — compiled by tailwind */
          @import "tailwindcss";
          .dash::before { content: "—"; }
        CSS
      end

      expect(generated_css).to match(/text-center/)
      expect(generated_css).not_to include('@import "tailwindcss"')
      expect(generated_css).to include("—")
    end
  end
end
