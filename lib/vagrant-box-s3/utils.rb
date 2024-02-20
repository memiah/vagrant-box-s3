require 'aws-sdk-s3'
require 'uri'

module VagrantPlugins
  module BoxS3
    class Utils

      # Match host style URLs, e.g.
      # https://bucket-name.s3.Region.amazonaws.com/key-name
      # https://bucket-name.s3-Region.amazonaws.com/key-name
      S3_URL_HOST_REGEX = %r{^https?://([\w\-\.]+)\.s3[-\.]([\w\-]+)\.amazonaws\.com/([^?]+)}

      # Match path style URLs e.g.
      # https://s3.Region.amazonaws.com/bucket-name/key-name
      # https://s3-Region.amazonaws.com/bucket-name/keyname
      S3_URL_PATH_REGEX = %r{^https?://s3[-\.]([\w\-]+)\.amazonaws\.com/([^/]+)/([^?]+)}

      # Check if URL matches S3 URLs.
      def self.is_s3_url(url)
        # Check if the URL matches either the host style or path style S3 URL
        matches_host_style = !!(url =~ S3_URL_HOST_REGEX)
        matches_path_style = !!(url =~ S3_URL_PATH_REGEX)

        # Return true if either match is found, false otherwise
        matches_host_style || matches_path_style
      end

      # Check if the URL is an S3 URL and the filename is 'manifest.json'
      def self.is_s3_manifest(url)
        uri = URI.parse(url)
        filename = File.basename(uri.path)

        return is_s3_url(url) && filename == 'manifest.json'
      end

      # Parse an s3 URL.
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
        end

        return region, bucket, key
      end

    end
  end
end
