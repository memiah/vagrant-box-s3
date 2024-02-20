require 'vagrant-box-s3/utils'

module Vagrant
  module Util
    class Downloader

      alias_method :original_head, :head

      def head
        if !VagrantPlugins::BoxS3::Utils.is_s3_url(@source) && !@source.include?('manifest.json')
          # If the source is not an S3 URL and does not contain 'manifest.json', use the original `head` implementation
          original_head
        else
          options, subprocess_options = self.options
          options.unshift("-i")
          options << @source

          @logger.info("HEAD (Override): #{@source}")
          result = execute_curl(options, subprocess_options)

          # Extract and return headers from result.stdout
          headers, _body = result.stdout.split("\r\n\r\n", 2)
          headers
        end
      end

    end
  end
end
