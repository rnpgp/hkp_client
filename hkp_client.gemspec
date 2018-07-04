
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hkp_client/version"

Gem::Specification.new do |spec|
  spec.name          = "hkp_client"
  spec.version       = HkpClient::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "A minimalist client for PGP public keyservers."
  spec.description   = "A minimalist HKP (OpenPGP HTTP Keyserver Protocol) " \
                       "client, which queries PGP public keyservers, " \
                       "and downloads public keys."
  spec.homepage      = "https://github.com/riboseinc/hkp_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry", "~> 0.11.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "vcr", "~> 4.0"
  spec.add_development_dependency "webmock"
end
