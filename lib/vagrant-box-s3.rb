require 'vagrant'

module VagrantPlugins
  module BoxS3
    class Plugin < Vagrant.plugin('2')
      name 'BoxS3'

      action_hook(:initialize_aliases) do |hook|
        require_relative 'vagrant-box-s3/downloader'
      end

    end
  end
end
