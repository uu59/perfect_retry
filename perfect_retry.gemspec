# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'perfect_retry/version'

Gem::Specification.new do |spec|
  spec.name          = "perfect_retry"
  spec.version       = PerfectRetry::VERSION
  spec.authors       = ["uu59"]
  spec.email         = ["k@uu59.org"]

  spec.summary       = %q{Retry handling kit}
  spec.description   = %q{Retry handling kit}
  spec.homepage      = "https://github.com/uu59/perfect_retry"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "codeclimate-test-reporter"
end
