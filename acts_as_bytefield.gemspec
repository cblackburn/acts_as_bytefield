# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_bytefield/version'

Gem::Specification.new do |spec|
  spec.name          = 'acts_as_bytefield'
  spec.version       = ActsAsBytefield::VERSION
  spec.authors       = ['Chris Blackburn']
  spec.email         = ['87a1779b@opayq.com']

  spec.summary       = 'Change an ActiveRecord string column into a byte field.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/cblackburn/acts_as_bytefield'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'midwire_common', '~> 1.1.1'
  spec.add_development_dependency 'pry-nav', '~> 0.2.4'
  spec.add_development_dependency 'sqlite3', '~> 1.3.11'

  spec.add_dependency 'activerecord', '~> 4.0'
end
