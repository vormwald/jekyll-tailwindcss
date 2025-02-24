## [Unreleased]

- Support importing official plugins in CSS for v4 [#22](https://github.com/vormwald/jekyll-tailwindcss/pull/22) @imustafin

## [0.6.1] - 2025-02-13

- Expand the matcher to match additional valid tailwindcss imports [#21](https://github.com/vormwald/jekyll-tailwindcss/pull/21)

## [0.6.0] - 2025-02-13

- Remove the unused jekyll-tailwindcss executable [#17](https://github.com/vormwald/jekyll-tailwindcss/pull/17)
- BIG Upgrade to TailwindCSS v4 [#18](https://github.com/vormwald/jekyll-tailwindcss/pull/18)

## [0.5.1]

- Fix a potential bug that would hang on large tailwind files - [#13](https://github.com/vormwald/jekyll-tailwindcss/pull/13) @marckohlbrugge

## [0.5.0]

- Location of `tailwind.config.js` can be specified in `_config.yml` - [#9](https://github.com/vormwald/jekyll-tailwindcss/pull/9) @imustafin

## [0.4.0] - 2024-11-23

### Changed

- The upstream `tailwindcss` executable has been extracted from this gem into a new dependency, `tailwindcss-ruby`.

  In advance of the upcoming TailwindCSS v4 release, we are decoupling the `tailwindcss` executable
  from the Rails integration. This will allow users to upgrade TailwindCSS at a time of their
  choosing, and allow early adopters to start using the beta releases.

## [0.3.1] - 2024-06-10

### Changed

- Update to [Tailwind CSS v3.4.12](https://github.com/tailwindlabs/tailwindcss/releases/tag/v3.4.12)

## [0.3.0] - 2024-06-09

### Changed

- Renamed the gems executable from `tailwindcss` to `jekyll-tailwindcss` to avoid conflicts with the `tailwindcss-rails` gem

### Added

- arm64-darwin platform support

## [0.2.0] - 2024-04-17

### Changed

- The plugin now converts any css file that contains frontmatter and a `@tailwind` directive
- No longer needs the extra files from initial version

### Added

- an integration test that runs in CI and confirms that the CLIs download correctly
- Better logging from the plugin. Any errors from tailwind are displayed as warns, and any errors from the gem are displayed as error level

## [0.1.0] - 2024-02-12

- Initial release
