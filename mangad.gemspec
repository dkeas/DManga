# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mangad/version'

Gem::Specification.new do |spec|
  spec.name          = "mangad"
  spec.version       = Mangad::VERSION
  spec.authors       = ["David Endrew"]
  spec.email         = ["david.edews@gmail.com"]

  spec.summary         = "Download mangas hosted in mangahost.net"
  # spec.description     = File.read(File.join(File.dirname(__FILE__), 'README.md'))
  spec.description     = "Download manga hosted in mangahost.net"
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency     "ruby-progressbar","~> 1.8"
  spec.add_runtime_dependency     "rainbow", "~> 2.2"
  spec.add_development_dependency "minitest","~> 5.10"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "bundler", "~> 1.14"
end
