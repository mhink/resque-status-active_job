# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/status/active_job/version'

Gem::Specification.new do |spec|
  spec.name          = "resque-status-active_job"
  spec.version       = Resque::Status::ActiveJob::VERSION
  spec.authors       = ["Matt Hink"]
  spec.email         = ["mhink1103@gmail.com"]

  spec.summary       = %q{Quick adapter allowing the use of the 'resque-status' gem with ActiveJob.}
  spec.homepage      = "https://github.com/mhink/resque-status-active_job"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  spec.add_runtime_dependency "resque-status", "~> 0.5.0"
  spec.add_runtime_dependency "activejob", "~>4.2"
  spec.add_runtime_dependency "activesupport", "~>4.2"

  spec.add_development_dependency "mock_redis", "~> 0.15.2"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-activejob"
end
