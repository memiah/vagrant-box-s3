
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vagrant-box-s3/version"

Gem::Specification.new do |spec|
  spec.name          = "vagrant-box-s3"
  spec.version       = VagrantPlugins::BoxS3::VERSION
  spec.authors       = ["Steve Whiteley"]
  spec.email         = ["steve@memiah.co.uk"]

  spec.summary       = %q{Amazon AWS S3 Auth.}
  spec.description   = %q{Private, versioned Vagrant boxes hosted on Amazon S3.}
  spec.homepage      = "https://github.com/memiah/vagrant-box-s3"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
#   if spec.respond_to?(:metadata)
#     spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
#
#     spec.metadata["homepage_uri"] = spec.homepage
#     spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
#     spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
#   else
#     raise "RubyGems 2.0 or newer is required to protect against " \
#       "public gem pushes."
#   end

  spec.files = Dir['lib/**/*', 'README.md', 'LICENSE.txt']
  spec.require_path = 'lib'

  spec.add_dependency 'aws-sdk-s3', '~> 1.143.0'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end
