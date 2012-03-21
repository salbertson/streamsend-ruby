# -*- encoding: utf-8 -*-
require File.expand_path('../lib/streamsend/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Scott Albertson"]
  gem.email         = %q{salbertson@streamsend.com}
  gem.summary       = %q{Ruby wrapper for the StreamSend API.}
  gem.description   = %q{Ruby wrapper for the StreamSend API.}
  gem.homepage      = %q{http://github.com/salbertson/streamsend-ruby}
  gem.date          = %q{2012-03-21}

  gem.add_dependency "httparty", "0.7.4"
  gem.add_development_dependency "rspec", "~> 2.5"
  gem.add_development_dependency "webmock", "~> 1.6"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "streamsend"
  gem.require_paths = ["lib"]
  gem.version       = Streamsend::VERSION
end
