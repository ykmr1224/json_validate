# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_validate/version'

Gem::Specification.new do |spec|
  spec.name          = "json_validate"
  spec.version       = JSONValidate::VERSION
  spec.authors       = ["Tomoyuki Morita"]
  spec.email         = ["ykmr1224@gmail.com"]
  spec.description   = %q{Offers simple way to validate JSON object having expected structure.}
  spec.summary       = %q{Offers simple way to validate JSON object having expected structure.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
