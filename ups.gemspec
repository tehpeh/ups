require File.expand_path('../lib/ups/version', __FILE__)
require 'English'

Gem::Specification.new do |gem|
  gem.name        = 'sellect-ups-ruby'
  gem.version     = UPS::Version::STRING
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ['Veeqo']
  gem.email       = ['helpme@veeqo.com']
  gem.homepage    = 'https://github.com/veeqo/ups-ruby'
  gem.summary     = 'UPS'
  gem.description = 'UPS Gem for accessing the UPS API from Ruby'

  gem.license     = 'MIT'

  gem.required_rubygems_version = '>= 1.3.6'

  gem.add_runtime_dependency 'ox', '~> 2.2', '>= 2.2.0'
  gem.add_runtime_dependency 'excon', '~> 0.45', '>= 0.45.3'
  gem.add_runtime_dependency 'insensitive_hash', '~> 0.3.3'
  gem.add_runtime_dependency 'levenshtein-ffi', '~> 1.1'

  gem.files        = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.require_path = 'lib'
end
