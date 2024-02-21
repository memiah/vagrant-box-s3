# Vagrant Box S3

[![Gem Version](https://badge.fury.io/rb/vagrant-box-s3.svg)](https://badge.fury.io/rb/vagrant-box-s3)

Use Vagrant boxes stored in Amazon S3 private buckets.

### Requirements

- [vagrant](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant) (2.4.x)
- [aws-sdk-s3](https://rubygems.org/gems/aws-sdk-s3/versions/1.143.0) (1.x)

## Features

This plugin works using the `authenticate_box_url` hook to replace S3 URLs with presigned URLs and monkey 
patching `Vagrant::Util::Downloader`, extending the core Downloader class in Vagrant to override the `head` method 
used when fetching box metadata URLs from S3.

## Installation

Via Vagrantfile, using [config.vagrant.plugins](https://developer.hashicorp.com/vagrant/docs/vagrantfile/vagrant_settings#config-vagrant-plugins): 

    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
      config.vagrant.plugins = ['vagrant-box-s3', 'other-plugin']
      ...
    end

Or via plugin install command:

    vagrant plugin install vagrant-box-s3

## Usage

The plugin will automatically sign requests to AWS S3 URLs with your AWS credentials, allowing storage of private
boxes on S3 with your own bucket policies in place.

## Configuration

AWS credentials are read from the standard environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

You can also use your credentials file to create a profile. Select the appropriate profile using the `AWS_PROFILE` environment variable. For example:

#### ~/.aws/credentials

    [vagrant-box-s3]
    aws_access_key_id = AKIA...
    aws_secret_access_key = ...

#### Vagrantfile

    ENV.delete_if { |name| name.start_with?('AWS_') }  # Filter out rogue env vars.
    ENV['AWS_PROFILE'] = 'vagrant-box-s3'

    Vagrant.configure("2") { |config| ... }

### S3 URLs

You can use any valid HTTP(S) URL for your box URL:

#### Path-Style URLs

Specify the bucket name in the path of the URL. AWS has deprecated path-style URLs, but they might still be seen or used in legacy systems.

- Format: https://s3.Region.amazonaws.com/bucket-name/key-name
- Example: https://s3.eu-west-1.amazonaws.com/mybucket/mybox.box


- Format: https://s3-Region.amazonaws.com/bucket-name/keyname
- Example: https://s3-eu-west-1.amazonaws.com/bucket-name/mybox.box

#### Virtual-Hosted-Style URLs
Virtual-hosted-style URLs use the bucket name as a subdomain. This is the recommended and most commonly used format.

- Format: https://bucket-name.s3.Region.amazonaws.com/key-name
- Example: https://mybucket.s3.eu-west-1.amazonaws.com/mybox.box

### IAM configuration

IAM accounts will need at least the following policy, replacing `BUCKET` with your bucket name.

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::BUCKET/*"
            },
            {
                "Effect": "Allow",
                "Action": ["s3:GetBucketLocation", "s3:ListBucket"],
                "Resource": "arn:aws:s3:::BUCKET"
            }
        ]
    }

## Development

### Requirements

- [Ruby](https://www.ruby-lang.org/en/downloads/) (3.2.x)

A specific version of ruby can be installed on macOS via rbenv:

    brew install rbenv

    echo 'eval "$(rbenv init -)"' >> ~/.zshrc

    rbenv install 3.2.2

    cd /path/to/vagrant-box-s3

    rbenv local 3.2.2

    ruby -v


### Builds

If bundled packages / dependencies have changed, run bundle install:

    bundle install --path vendor/bundle

Update the current version in `lib/vagrant-box-s3/version.rb`.

### Dev build and test

To build the plugin, use `rake build`, this will create a file with the current version number, e.g. `pkg/vagrant-box-s3-{VERSION}.gem`.

Remove the old version:

    vagrant plugin uninstall vagrant-box-s3 --local

Testing the plugin requires installing into vagrant from the build:

    vagrant plugin install ../vagrant-box-s3/pkg/vagrant-box-s3-{VERSION}.gem

Then running a command that will trigger box URL related actions, such as `vagrant up`, `vagrant box update` etc. with the `--debug` flag.

### Releases

To release a new version to [RubyGems.org](https://rubygems.org/gems/vagrant-box-s3), you must be authenticated.

If you have not previously authenticated, sign in:

    gem signin

This will store and use credentials in `~/.gem/credentials`.

Ensure the new version number is correctly set in `lib/vagrant-box-s3/version.rb`.

Then you can build and push the release:

    rake release

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/memiah/vagrant-box-s3. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
