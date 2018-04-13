# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_dependency 'httparty', '>= 0.15'
  spec.authors = ["Nexosis,Inc"]
  spec.description = %q{Nexosis API client}
  spec.email = ['support@nexosis.com']
  spec.files = %w(nexosisapi.gemspec)
  spec.files += Dir.glob("lib/**/*.rb")
  spec.homepage = 'https://github.com/nexosis/nexosisclient-rb'
  spec.licenses = ['Apache-2.0']
  spec.name = 'nexosis_api'
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3.0'
  spec.summary = "Ruby client for working with the Nexosis API"
  spec.version = '3.0.1'
  spec.metadata["yard.run"] = "yri"
end