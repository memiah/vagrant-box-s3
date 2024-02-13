require 'aws-sdk-s3'
require 'uri'

module VagrantPlugins
  module BoxS3
    class Utils

      # Match host style URLs, e.g.
      # https://bucket-name.s3.Region.amazonaws.com/key-name
      S3_URL_HOST_REGEX = %r{^https?://([\w\-\.]+)\.s3\.([\w\-]+)\.amazonaws\.com/([^?]+)}

      # Match path style URLs e.g.
      # https://s3.Region.amazonaws.com/bucket-name/key-name
      # https://s3-Region.amazonaws.com/bucket-name/keyname
      S3_URL_PATH_REGEX = %r{^https?://s3[-\.]([\w\-]+)\.amazonaws\.com/([^/]+)/([^?]+)}

      # Parse an s3 URL.
      def self.parse_s3_url(s3_url)
        region = bucket = key = nil
        if s3_url =~ S3_URL_HOST_REGEX
          match = S3_URL_HOST_REGEX.match(s3_url)
          region = match[2]
          bucket = match[1]
          key = match[3]
        elsif s3_url =~ S3_URL_PATH_REGEX
          match = S3_URL_PATH_REGEX.match(s3_url)
          region = match[1]
          bucket = match[2]
          key = match[3]
        end

        return region, bucket, key
      end

      # Pre-sign an s3 URL, with given method.
      def self.presign_url(method, url, logger)
          logger.info("BoxS3: Generating signed URL for #{method.upcase}")
          logger.info("BoxS3: Discovered S3 URL: #{url}")

          region, bucket, key = parse_s3_url(url)

          logger.debug("BoxS3: Region: #{region}")
          logger.debug("BoxS3: Bucket: #{bucket}")
          logger.debug("BoxS3: Key: #{key}")

          client = Aws::S3::Client.new(
            profile: ENV['AWS_PROFILE'],
            region: region
          )
          presigner = Aws::S3::Presigner.new(client: client)

          presigned_url = presigner.presigned_url(
            method,
            bucket: bucket,
            key: key,
            expires_in: 3600
          ).to_s

          logger.debug("BoxS3: Pre-signed URL: #{presigned_url}")

          return presigned_url
      end

    end
  end
end
