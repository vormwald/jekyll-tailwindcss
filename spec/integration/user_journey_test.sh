#! /usr/bin/env bash
# reproduce the documented user journey for installing and running jekyll-tailwindcss
# this is run in the CI pipeline, non-zero exit code indicates a failure

set -o pipefail
set -eux

# set up dependencies
rm -f Gemfile.lock
bundle install

# fetch the upstream executables
bundle exec rake download

# do our work a directory with spaces in the name
rm -rf "My Workspace"
mkdir "My Workspace"
pushd "My Workspace"

# create a jekyll project
bundle exec jekyll -v
bundle exec jekyll new test-site --skip-bundle
pushd test-site

# trying a fix from https://github.com/Maher4Ever/wdm/issues/27
gem install wdm -- --with-cflags=-Wno-implicit-function-declaration

# make sure to use the same version of jekyll
bundle remove jekyll
bundle add jekyll --skip-install

# use the jekyll-tailwindcss under test
bundle add jekyll-tailwindcss --path="../.."
bundle install
bundle show --paths

# install tailwindcss config
bundle exec jekyll-tailwindcss init

# TEST: tailwind was installed correctly
grep tailwind tailwind.config.js
