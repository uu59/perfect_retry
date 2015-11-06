[![Build Status](https://travis-ci.org/uu59/perfect_retry.svg?branch=master)](https://travis-ci.org/uu59/perfect_retry)
[![Code Climate](https://codeclimate.com/github/uu59/perfect_retry/badges/gpa.svg)](https://codeclimate.com/github/uu59/perfect_retry)
[![Test Coverage](https://codeclimate.com/github/uu59/perfect_retry/badges/coverage.svg)](https://codeclimate.com/github/uu59/perfect_retry/coverage)
[![Gem Version](https://badge.fury.io/rb/perfect_retry.svg)](https://badge.fury.io/rb/perfect_retry)

# PerfectRetry

Implement to handle retry kit.

## Usage and Config

```ruby
PerfectRetry.with_retry do
  do_something_have_possibilities_errors_task()
end
```

```ruby
# in setup.rb

require "timeout"

PerfectRetry.register(:timeout_handling) do |config|
  # Try 4 times retry.
  # default: 3
  config.limit = 4

  # Rescue these error in a block.
  # default: [StandardError]
  config.rescues = [Timeout::Error, StandardError]

  # Sleep this seconds before next retry. `n` is a retry times (1-origin).
  # Infinity retry if `nil` is set.
  # default: proc{|n| n ** 2}
  config.sleep = proc{|n| n * 5 }

  # Logger for something information e.g. '[2/5] Retrying after 3 seconds blah blah'.
  # default: Logger.new(STDERR)
  config.logger = Logger.new("/var/log/agent.log")

  # Ensure block. Call this block after with_retry block finished with and without any errors.
  # default: proc {}
  config.ensure = proc { puts "finished" }
end

# in main.rb

require "open-uri"

PerfectRetry.new(:timeout_handling).with_retry do
  open("http://example.com")
end

# or

PerfectRetry.with_retry(:timeout_handling) do
  open("http://example.com")
end
```

### Custom config without register

```ruby
pr = PerfectRetry.new do |config|
  # based on default config
  config.sleep = 1
  config.rescues = [Timeout::Error]
end

pr.with_retry do
  open("http://example.com")
end

# Also you can extend registered config
pr = PerfectRetry.new(:some_registered) do |config|
  config.ensure = proc{ puts "done" }
end

pr.with_retry do
  # something to do
end
```


### Manually retry 

```ruby
PerfectRetry.register(:dont_retry_automatically) do |config|
  config.limit = 0
end

PerfectRetry.with_retry(:dont_retry_automatically) do
  response = HTTPClient.get("http://example.com")
  if response.code == 500
    sleep 3
    throw :retry
  end
end
```

`throw :retry` redo the block at first without `config.limit` checking. In above case, infinity retry while example.com returns 500.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'perfect_retry'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install perfect_retry

# See also

- [retryable](https://github.com/nfedyashev/retryable)
- [retry-handler](https://github.com/kimoto/retry-handler)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

