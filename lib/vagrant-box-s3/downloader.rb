require 'vagrant-box-s3/utils'

module Vagrant
  module Util
    class Downloader

      alias_method :original_head, :head

      def head
        if VagrantPlugins::BoxS3::Utils.is_s3_manifest(@source)
          options, subprocess_options = self.options
          options.unshift("-i")
          options << @source

          @logger.info("HEAD (Override): #{@source}")
          result = execute_curl(options, subprocess_options)

          headers, _body = result.stdout.split("\r\n\r\n", 2)
          headers
        else
          original_head
        end
      end

    end
  end
end
