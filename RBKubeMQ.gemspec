# lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rake"

Gem::Specification.new do |s|
  s.name        = 'rbkubemq'
  s.version	    = '0.1.4'
  s.authors     = ['Stefano Martin']
  s.email       = ['stefano@seluxit.com']
  s.homepage    = 'https://github.com/Seluxit/RBKubeMQ'
  s.license     = 'MIT'
  s.summary     = 'A simple gem for KubeMQ'
  s.description = "Ruby driver for KubeMQ"
  s.required_ruby_version = '>= 2.5.0'
  s.platform	   = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.files         = FileList['lib/**/*', 'RBKubeMQ.gemspec', 'Gemfile', 'LICENSE', 'README.md'].to_a
  s.add_dependency 'httparty', '~> 0', '>= 0.14.0'
  s.add_dependency 'oj', '~> 3', '>=  3.6.11'
  s.add_dependency 'faye-websocket', '~> 0', '>=  0.10.7'
end
