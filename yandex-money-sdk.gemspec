# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'yandex_money/api/version'

Gem::Specification.new do |spec|
  spec.name          = "yandex-money-sdk"
  spec.description   = "SDK for Yandex Money API"
  spec.version       = YandexMoney::Api::VERSION
  spec.authors       = ["Alexander Maslov"]
  spec.email         = ["drakmail@delta.pm"]
  spec.summary       = %q{Yandex money API for ruby.}
  spec.homepage      = "https://github.com/yandex-money/yandex-money-sdk-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", '~> 0.13', ">= 0.13.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3", ">= 10.3.2"
  spec.add_development_dependency "vcr", "~> 2.9", ">= 2.9.3"
  spec.add_development_dependency "webmock", "~> 1.8", ">= 1.8.0"
  spec.add_development_dependency "rspec", "~> 3.1", ">= 3.1.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.1", ">= 3.1.0"
end
