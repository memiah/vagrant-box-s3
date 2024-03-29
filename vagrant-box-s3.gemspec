
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vagrant-box-s3/version"

Gem::Specification.new do |spec|
  spec.name          = "vagrant-box-s3"
  spec.version       = VagrantPlugins::BoxS3::VERSION
  spec.authors       = ["Steve Whiteley"]
  spec.email         = ["opensource@memiah.co.uk"]

  spec.summary       = %q{Amazon AWS S3 Auth.}
  spec.description   = %q{Private, versioned Vagrant boxes hosted on Amazon S3.}
  spec.homepage      = "https://github.com/memiah/vagrant-box-s3"
  spec.license       = "MIT"

  spec.metadata = {
    "source_code_uri" => "https://github.com/memiah/vagrant-box-s3",
    "bug_tracker_uri" => "https://github.com/memiah/vagrant-box-s3/issues"
  }

  spec.required_rubygems_version = '>= 3.0.0'

  spec.files = Dir['lib/**/*', 'README.md', 'LICENSE.txt']
  spec.require_path = 'lib'

  spec.add_dependency 'aws-sdk-s3', '~> 1.143.0'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end
