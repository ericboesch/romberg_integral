# Romberg Integral

A pure Ruby implementation of Romberg numerical integration in one
variable.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'romberg_integral'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install romberg_integral

## Usage

    require "romberg_integral"

    # Numerically integrate 1/x between 1 and 10
    ri = RombergIntegral.new

    # If you wish to change the error thresholds from their default values:
    ri.max_call_cnt = 1025
    ri.min_call_cnt = 9
    ri.relative_error = 1e-9
    ri.absolute_error = 1e-40

    estimate = ri.integral(1, 10) { |x| 1.0/x }
    actual = Math.log 10
    error = (actual - estimate.value).abs
    puts (estimate.aborted ? "Failed": "Success")
    puts "True error = #{error} after #{estimate.call_cnt} calls."
    puts estimate

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ericboesch/romberg_integral.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
