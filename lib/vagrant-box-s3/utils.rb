require 'aws-sdk-s3'
require 'uri'

module VagrantPlugins
  module BoxS3
    class Utils

      # Match standard AWS S3 URLs:
      # https://bucket-name.s3.Region.amazonaws.com/key-name
      # https://s3.Region.amazonaws.com/bucket-name/key-name
      S3_URL_HOST_REGEX = %r{^https?://([\w\-\.]+)\.s3[-\.]([\w\-]+)\.amazonaws\.com/([^?]+)}
      S3_URL_PATH_REGEX = %r{^https?://s3[-\.]([\w\-]+)\.amazonaws\.com/([^/]+)/([^?]+)}

      # Check if URL matches S3 URL.
      #
      # For custom S3 endpoints, use AWS_ENDPOINT_URL and accept:
      # https://endpoint/bucket/key
      #
      def self.is_s3_url(url)
        matches_host_style = !!(url =~ S3_URL_HOST_REGEX)
        matches_path_style = !!(url =~ S3_URL_PATH_REGEX)

        if matches_host_style || matches_path_style
          return true
        end

        custom_endpoint = ENV['AWS_ENDPOINT_URL']

        if custom_endpoint && !custom_endpoint.empty?
          begin
            uri = URI.parse(url)
            endpoint = URI.parse(custom_endpoint)

            return (
              uri.scheme == endpoint.scheme &&
              uri.host == endpoint.host &&
              uri.port == endpoint.port &&
              uri.path.split('/').reject(&:empty?).length >= 2
            )
          rescue URI::InvalidURIError
            return false
          end
        end

        false
      end

      def self.is_s3_manifest(url)
        uri = URI.parse(url)
        filename = File.basename(uri.path)

         return is_s3_url(url) &&
                ['manifest.json', 'metadata.json'].include?(filename)
        return is_s3_url(url) && filename == 'manifest.json'
      end

      # Parse an S3 URL.
      #
      # For AWS URLs, parse the region from the hostname.
      # For custom endpoints, region comes from AWS configuration.
      def self.parse_s3_url(url)
        region = bucket = key = nil

        if url =~ S3_URL_HOST_REGEX
          match = S3_URL_HOST_REGEX.match(url)
          region = match[2]
          bucket = match[1]
          key = match[3]

        elsif url =~ S3_URL_PATH_REGEX
          match = S3_URL_PATH_REGEX.match(url)
          region = match[1]
          bucket = match[2]
          key = match[3]

        else
          custom_endpoint = ENV['AWS_ENDPOINT_URL']

          if custom_endpoint && !custom_endpoint.empty?
            begin
              uri = URI.parse(url)
              endpoint = URI.parse(custom_endpoint)

              if uri.scheme == endpoint.scheme &&
                 uri.host == endpoint.host &&
                 uri.port == endpoint.port

                parts = uri.path.split('/').reject(&:empty?)

                if parts.length >= 2
                  bucket = parts.shift
                  key = parts.join('/')
                  region = ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION']

                  if !region || region.empty?
                    region = 'us-east-1'
                  end
                end
              end
            rescue URI::InvalidURIError
            end
          end
        end

        return region, bucket, key
      end

    end
  end
end