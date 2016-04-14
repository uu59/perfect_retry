# 0.5.0 2016-04-14

- [enhancement] Add `prefer_original_backtrace` and `raise_original_error` options. [#6](https://github.com/uu59/perfect_retry/pull/6)

# 0.4.0 2016-01-19

- [enhancement] Add `PerfectRetry.disable!` and `PerfectRetry.enable!` for testing. [#5](https://github.com/uu59/perfect_retry/pull/5)

# 0.3.2 2015-11-16

- [fixed] Don't warn if `log_level` is nil and logger doesn't have `level=` method.

# 0.3.1 2015-11-13

- [fixed] Ignore `log_level` config when logger doesn't have `level=` method [#3](https://github.com/uu59/perfect_retry/pull/3)

# 0.3.0 2015-11-09

- [enhancement] Logging backtrace as debug level. [#2](https://github.com/uu59/perfect_retry/pull/2)
- [enhancement] Add `log_level` option(default: warn) [#2](https://github.com/uu59/perfect_retry/pull/2)

# 0.2.0 2015-11-09

- [enhancement] Add `dont_rescues` option.

# 0.1.0 2015-11-06

- [enhancement] Configure with block on initialize

# 0.0.1 2015-11-05

First release.
