# Jekyll::Tailwindcss

## Installation

Install the gem in your jekyll project's Gemfile by executing the following:

```sh
$ bundle add jekyll-tailwindcss
```

Add it to your list of jekyll-plugins

```yml
plugins:
  - jekyll-tailwindcss
```

## Usage

Currently, this gem assumes you have several files in your project:

**`tailwind.config.js`**

This is the tailwind configuration for your project. Learn [more here](https://tailwindcss.com/docs/configuration).

**`_input.css`**

This file will contain your tailwind directives and any custom classes. Read more in the [docs here](https://tailwindcss.com/docs/functions-and-directives#config)

**`*.tailwindcss`**

Any files with this extension (and contain [frontmatter](https://jekyllrb.com/docs/front-matter/)) will be processed by tailwind, and converted into a corresponding filename with a `.css` extension.

For instance, `assets/css/styles.tailwindcss` will convert to `_site/assets/css/styles.css`


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vormwald/jekyll-tailwindcss. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/vormwald/jekyll-tailwindcss/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jekyll::Tailwindcss project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/vormwald/jekyll-tailwindcss/blob/main/CODE_OF_CONDUCT.md).
