require 'vagrant'
require 'vagrant-box-s3/urls'

module VagrantPlugins
  module BoxS3
    class Plugin < Vagrant.plugin('2')
      name 'BoxS3'

      action_hook(:initialize_aliases) do |hook|
        require_relative 'vagrant-box-s3/downloader'
      end

      action_hook(:box_s3_url, :authenticate_box_url) do |hook|
        hook.prepend(Urls)
      end

    end
  end
end
