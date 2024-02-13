require 'vagrant-box-s3/utils'

module Vagrant
  module Util
    class Downloader

      def aws_auth_download(options, subprocess_options, &data_proc)
        # Get URL from options, which is the last option in the list.
        url = options.last

        # Determine method from curl command -I flag existence.
        method = options.any? { |o| o == '-I' } ? :head_object : :get_object

        # Generate pre-signed URL from S3 URL.
        presigned_url = VagrantPlugins::BoxS3::Utils.presign_url(method, url, @logger)

        # Update URL in options.
        url.replace(presigned_url.to_s)

        # Call original execute_curl (aliased).
        execute_curl_without_aws_auth(options, subprocess_options, &data_proc)

      rescue Aws::S3::Errors::Forbidden => e
        message = "403 Forbidden: #{e.message}"
        raise Errors::DownloaderError, message: message
      rescue Seahorse::Client::NetworkingError => e
        raise Errors::DownloaderError, message: e
      end

      def execute_curl_with_aws_auth(options, subprocess_options, &data_proc)
        options = options.dup
        url = options.find { |o| o =~ /^http/ }

        if url && url.include?('amazonaws.com')
          aws_auth_download(options, subprocess_options, &data_proc)
        else
          execute_curl_without_aws_auth(options, subprocess_options, &data_proc)
        end
      end

      alias execute_curl_without_aws_auth execute_curl
      alias execute_curl execute_curl_with_aws_auth

    end
  end
end
