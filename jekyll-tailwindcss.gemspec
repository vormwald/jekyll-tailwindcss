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
  spec.required_ruby_version = ">= 3.0.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.files = Dir["{app,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  spec.bindir = "exe"
  spec.executables << "jekyll-tailwindcss"
  spec.require_paths = ["lib"]
end
