# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in jekyll-tailwindcss.gemspec
gemspec

gem "rake", "~> 13.0"
gem "jekyll", "~> 4.3"
gem "rspec", "~> 3.0"
gem "standard", "~> 1.3"

# needed as a jekyll dependency since ruby 3.4/4.0 removed them
gem "csv"
gem "logger"
gem "base64"
gem "logger"

# transitive deps whose newer releases require ruby >= 3.2; CI still tests ruby 3.1
gem "rdoc", "< 8" # rdoc 8 requires ruby >= 3.2 and pulls in rbs (also >= 3.2)
gem "erb", "< 5" # erb >= 6 requires ruby >= 3.2
gem "sass-embedded", "< 1.77.1" # sass-embedded >= 1.77.1 requires ruby >= 3.2

group :development, :test do
  gem "irb", "~> 1.14"
end
