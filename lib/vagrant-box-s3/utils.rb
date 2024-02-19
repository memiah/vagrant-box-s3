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

      # Remove presigned URL params from box URL.
      # We do this as URLs can be cached and do not want to want
      # to include previously presigned URL parameters.
      def self.remove_presigned_params(url)
        # Parse the URL
        uri = URI.parse(url)

        # Split the query string into parameters
        query_params = URI.decode_www_form(uri.query || '').to_h

        # Remove any parameters that start with 'X-Amz-'
        query_params.reject! { |k, _| k.start_with?('X-Amz-') }

        # Check if there are any query parameters left
        if query_params.empty?
          # If no query parameters left, set uri.query to nil to remove the '?'
          uri.query = nil
        else
          # Reconstruct the query string without AWS presigned parameters
          uri.query = URI.encode_www_form(query_params)
        end

        return uri.to_s
      end

      # Pre-sign an s3 URL, with given method.
      def self.presign_url(method, url, logger)

        url = remove_presigned_params(url)

        logger.info("BoxS3: Generating signed URL for #{method.upcase}")
        logger.info("BoxS3: Discovered S3 URL: #{url}")

        region, bucket, key = parse_s3_url(url)

        profile = ENV['AWS_PROFILE']

        logger.debug("BoxS3: Region: #{region}")
        logger.debug("BoxS3: Bucket: #{bucket}")
        logger.debug("BoxS3: Key: #{key}")
        logger.debug("BoxS3: Profile: #{profile}")

        client = Aws::S3::Client.new(
          profile: profile,
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
