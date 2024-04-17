## [Unreleased]

## [0.2.0] - 2024-04-17

### Changed
- The plugin now converts any css file that contains frontmatter and a `@tailwind` directive
- No longer needs the extra files from initial version

### Added
- an integration test that runs in CI and confirms that the CLIs download correctly
- Better logging from the plugin. Any errors from tailwind are displayed as warns, and any errors from the gem are displayed as error level

## [0.1.0] - 2024-02-12

- Initial release
