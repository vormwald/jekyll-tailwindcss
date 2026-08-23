# frozen_string_literal: true

require_relative "lib/jekyll-tailwindcss/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-tailwindcss"
  spec.version = Jekyll::Tailwindcss::VERSION
  spec.authors = ["Mike Vormwald"]
  spec.email = ["mvormwald@gmail.com"]
  spec.summary = "Integrate Tailwind CSS into your Jekyll site."
  spec.homepage = "https://github.com/vormwald/jekyll-tailwindcss"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/vormwald/jekyll-tailwindcss/blob/main/CHANGELOG.md"
  spec.metadata["source_code_uri"] = "https://github.com/vormwald/jekyll-tailwindcss"
  spec.metadata["bug_tracker_uri"] = "https://github.com/vormwald/jekyll-tailwindcss/issues"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.files = Dir["{app,lib}/**/*", "LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]
  spec.add_dependency "tailwindcss-ruby"
end
