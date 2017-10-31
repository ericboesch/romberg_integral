# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "romberg_integral/version"

Gem::Specification.new do |spec|
  spec.name          = "romberg_integral"
  spec.version       = RombergIntegral::VERSION
  spec.authors       = ["Eric Boesch"]
  spec.email         = ["ericboesch@gmail.com"]

  spec.summary       = %q{Romberg numerical integration class.}
  spec.homepage      = "https://github.com/ericboesch/romberg_integral"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
