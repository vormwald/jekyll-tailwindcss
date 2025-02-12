# Jekyll::Tailwindcss

Bring the fun of building with TailwindCSS into your Jekyll project (without any JavaScript)

**TL;DR** This gem borrows _heavily_ from [tailwindcss-rails](https://github.com/rails/tailwindcss-rails) to provide platform-specific tailwind executables and provide a smooth developer experience in Jekyll projects

> “Because building a great jekyll site shouldn’t require a `node_modules` folder

## Installation

Install the gem in your jekyll project's Gemfile by executing the following:

```
bundle add jekyll-tailwindcss
```

Add the plugin to your list of jekyll plugins in `_config.yml`

```yml
plugins:
  - jekyll-tailwindcss
```

## Tailwind Configuration

This plugin requires you to have a tailwind configuration file (`tailwind.config.js`) at the root level of your project. Tailwind will include the CSS for the classes found in `content` directories. For most jekyll sites, this would work well.

```js
  content: [
    "./_drafts/**/*.md",
    "./_includes/**/*.html",
    "./_layouts/**/*.html",
    "./_pages/*.{html,md}",
    "./_posts/*.md",
    "./*.{html,md}",
  ],
```

Learn more at https://tailwindcss.com/docs/configuration

## Usage

```sh
bundle exec jekyll serve # or build
```

Any `*.css` file processed by jekyll [^1] that contains the `@tailwind` [directive](https://tailwindcss.com/docs/functions-and-directives#config) will now be converted through the Tailwind CLI.

[^1]: Jekyll will process any file that begins with yaml [frontmatter](https://jekyllrb.com/docs/front-matter/)

### Configuration

Location of the `tailwind.config.js` file can be configured in `_config.yml`:

```yaml
tailwindcss:
  config: "./tailwind.config.js" # this is the default location
```

### Examples

A CSS file with frontmatter and `@tailwind` directives:

```css
/* assets/css/styles.css */
---
# This yaml frontmatter is required for jekyll to process the file
---

@tailwind base;
@tailwind components;
@tailwind utilities;

.btn {
  @apply font-bold py-2 px-4 rounded !important;
}
```

will be converted to

```css
/* _site/assets/css/styles.css */

/*
 * Tailwind generated CSS 
 * ...
 */
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem on your local machine, run `bundle exec rake install`.

## Testing this gem

### Running the test suite

The unit tests are run with `bundle exec rspec`

### Testing in a Jekyll project

If you want to test modifications to this gem, you must run `rake download` once to download the upstream `tailwindcss` executables.

Then you can point your Jekyll project's `Gemfile` at the local version of the gem as you normally would:

```ruby
gem "jekyll-tailwindcss", path: "/path/to/jekyll-tailwindcss"
```

### Cutting a release

- bump the version
  - [ ] update `lib/jekyll-tailwindcss/version.rb`
  - [ ] update `CHANGELOG.md`
  - [ ] commit and create a git tag ( example `git tag -a v0.3.1 -m "Release 0.3.1"` )
- push
  - [ ] `bundle exec rake build`
  - [ ] `gem push pkg/jekyll-tailwind-[NEW_VERSION].gem
  - [ ] `git push --follow-tags`
- announce
  - [ ] create a release at https://github.com/vormwald/jekyll-tailwindcss/releases

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vormwald/jekyll-tailwindcss. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/vormwald/jekyll-tailwindcss/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jekyll::Tailwindcss project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/vormwald/jekyll-tailwindcss/blob/main/CODE_OF_CONDUCT.md).
