# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dmanga/version'

Gem::Specification.new do |spec|
    spec.name          = "dmanga"
    spec.version       = DManga::VERSION
    spec.authors       = ["David Endrew"]
    spec.email         = ["david.edews@gmail.com"]

    spec.summary         = "Downloads any manga from mangahost.net"
    spec.description     = "Downloads any manga from mangahost.net. You can search and " +
        "select any chapter or range of chapters"
    spec.homepage      = "https://github.com/david-endrew/DManga"
    spec.license       = "MIT"

    # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
    # to allow pushing to a single host or delete this section to allow pushing to any host.
    #if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "http://mygemserver.com'"
    #else
    #raise "RubyGems 2.0 or newer is required to protect against " \
    #"public gem pushes."
    #end

    spec.files         = `git ls-files -z`.split("\x0").reject do |f|
        f.match(%r{^(test|spec|features)/})
    end
    spec.bindir        = "exe"
    spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
    spec.require_paths = ["lib"]

    spec.add_runtime_dependency     "ruby-progressbar","~> 1.9"
    spec.add_runtime_dependency     "addressable","~> 2.5"
    spec.add_runtime_dependency     "rubyzip","~> 1.2"
    spec.add_runtime_dependency     "formatador", "~> 0.2"
    spec.add_development_dependency "minitest","~> 5.11"
    spec.add_development_dependency "webmock", "~> 3.3"
    spec.add_development_dependency "rake", "~> 12.3"
    spec.add_development_dependency "bundler", "~> 1.16"
end
