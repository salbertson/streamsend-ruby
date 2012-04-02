# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Scott Albertson"]
  gem.email         = %q{salbertson@streamsend.com}
  gem.summary       = %q{Ruby wrapper for the StreamSend API.}
  gem.description   = %q{Ruby wrapper for the StreamSend API.}
  gem.homepage      = %q{http://github.com/salbertson/streamsend-ruby}
  gem.date          = %q{2012-04-02}

  gem.add_dependency "httparty", "0.7.4"
  gem.add_development_dependency "rspec", "~> 2.9"
  gem.add_development_dependency "webmock", "~> 1.6"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "streamsend"
  gem.require_paths = ["lib"]
  gem.version       = "0.1.2"
end
