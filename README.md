# Jekyll::Tailwindcss

Bring the joy of building with TailwindCSS into your Jekyll project (without any JavaScript)

**TL;DR** This gem uses [tailwindcss-ruby](https://github.com/rails/tailwindcss-ruby) to provide platform-specific tailwind executables and enables a smooth developer experience in Jekyll projects

> _"Because building a great Jekyll site shouldn't require a `node_modules` folder"_


## Installation

Add the gem to your Jekyll project's Gemfile

```ruby
# Gemfile
# ...
group :jekyll_plugins do
 # ...
 gem "jekyll-tailwindcss"
end
```

Run `bundle install`

> [!TIP]
> By adding this gem to the `:jekyll_plugins` group, you don't need to explicitly configure it in `_config.yml`.

### Optional: Choosing a specific version of tailwindcss

This gem uses the latest TailwindCSS by default. However since CLI versions are managed by the `tailwindcss-ruby` gem, it supports older versions as well.

You can use an older Tailwind version by specifying it in your Gemfile:

```ruby
# Gemfile
# ...
group :jekyll_plugins do
 # ...
 gem "jekyll-tailwindcss"
end
# gem versions track against tailwind releases
gem "tailwindcss-ruby", "~> 3.4"
```

<details>

<summary>Tailwind Version 3 Setup</summary>

Tailwind V3 required a tailwind configuration file (`tailwind.config.js`), which needs to be specified in `_config.yml`:

```yaml
tailwindcss:
  config: "./tailwind.config.js"
```

Tailwind will generate CSS for the classes found in `content` directories. For most Jekyll sites, this would work well.

```js
// ./tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./_drafts/**/*.md",
    "./_includes/**/*.html",
    "./_layouts/**/*.html",
    "./_pages/*.{html,md}",
    "./_posts/*.md",
    "./*.{html,md}",
  ],
  // ...
};
```

Learn more at https://v3.tailwindcss.com/docs/configuration

## Example CSS

Any CSS file with frontmatter and `@tailwind` directives will be converted.

```css
/* assets/css/styles.css */
---
# This yaml frontmatter is required for Jekyll to process the file
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

### PostCSS Support

> [!WARNING]
> PostCSS configuration is considered an advanced use case and is outside the scope of this gem.
> It is possible that support be removed in future versions of this gem. If needed, you should look to run your Tailwind builds with node.

That said... This gem includes basic PostCSS support. If a `postcss.config.js` file is included in your `_config.yml`, the Tailwind CLI will be invoked with the `--postcss` flag.

Users should verify their PostCSS setup outside this gem by running:
 `bundle exec tailwindcss --postcss postcss.config.js`

```yaml
tailwindcss:
  config: "./tailwind.config.js" # this is the default location
  postcss: "./postcss.config.js" # OPTIONAL, only if you have a postcss config file
```


</details>

## Usage

> See an example repo at https://github.com/vormwald/jekyll-blahg

### Setup
You'll need 2 files to make this work:

**File 1: `./_tailwind.css`**

This file acts as your tailwind configuration file. Import "tailwindcss" and any custom CSS here.

```css
@import "tailwindcss";

/* ... any other imports or css classes */
```


**File 2: `./assets/css/styles.tailwindcss`**

Place this file wherever you'd like your site's tailwind CLI generated content to go: `assets/css/your_css_file.tailwindcss` -> `__site/assets/css/your_css_file.css`

It must contain yaml frontmatter to be processed by Jekyll [^1]

```yaml
---
# This file will be converted to __site/assets/css/styles.css
---
This file is just a placeholder. It's content will be replaced by output from the tailwindcss CLI.
```

> [!NOTE]
> Why the 2 files?
>
> This is a compromise to allow the [TailwindCSS intellisense](https://tailwindcss.com/docs/editor-setup#intellisense-for-vs-code) plugin to work. (It cannot parse a CSS file with frontmatter, so we keep it seperate)
>
> The `_tailwind.css` file serves as the tailwindcss config file.
> If you'd rather set keep this file somewhere else, you can do so by setting the `tailwindcss.config_file` option in `_config.yml`:
>
> ```yaml
> tailwindcss:
>   css_path: ./_data/tailwind.css
> ```

### Building the Jekyll site

```sh
bundle exec jekyll serve
```
[^1]: Jekyll will process any file that begins with yaml [frontmatter](https://jekyllrb.com/docs/front-matter/)


### Minification

The `--minify` flag is automatically added when the `JEKYLL_ENV` environment variable is present and set to anything other than `development`. [Jekyll Docs](https://jekyllrb.com/docs/configuration/environments/)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem on your local machine, run `bundle exec rake install`.

## Testing this gem

### Running the test suite

The unit tests are run with `bundle exec rspec`

### Testing in a Jekyll project

If you want to test modifications to this gem, you can point your Jekyll project's `Gemfile` at the local version of the gem as you normally would:

```ruby
# Gemfile
# ...
group :jekyll_plugins do
 # ...
  gem "jekyll-tailwindcss", path: "/path/to/jekyll-tailwindcss"
end
```

### Cutting a release

- bump the version
  - [ ] update `lib/jekyll-tailwindcss/version.rb`
  - [ ] update `CHANGELOG.md`
  - [ ] bundle install to pick up the new version
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
