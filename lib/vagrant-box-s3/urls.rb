require 'log4r'
require 'vagrant-box-s3/utils'

module VagrantPlugins
  module BoxS3
    class Urls
      def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant::plugins::box_s3')
        end

        def call(env)
          # Assume 'env[:box_urls]' contains the original URLs that need authentication
          original_urls = env[:box_urls]

          # Your logic to authenticate the URLs goes here
          # This is just an example, replace it with your actual authentication mechanism
          authenticated_urls = original_urls.map do |url|
            presign_url(url)
          end

          # Ensure the authenticated URLs are set back in the environment
          env[:box_urls] = authenticated_urls

          # Continue the middleware chain
          @app.call(env)
        end

        private

        # Pre-sign an s3 URL, with given method.
        def presign_url(url)

          # Check if the URL is an S3 URL.
          if !Utils.is_s3_url(url)
            @logger.info("Skipping presigner for #{url}")
            return url
          end

          @logger.info("Discovered S3 URL: #{url}")

          region, bucket, key = Utils.parse_s3_url(url)

          profile = ENV['AWS_PROFILE']

          @logger.debug("Region: #{region}")
          @logger.debug("Bucket: #{bucket}")
          @logger.debug("Key: #{key}")
          @logger.debug("Profile: #{profile}")

          client = Aws::S3::Client.new(
            profile: profile,
            region: region
          )
          presigner = Aws::S3::Presigner.new(client: client)

          presigned_url = presigner.presigned_url(
            :get_object,
            bucket: bucket,
            key: key,
            expires_in: 3600
          ).to_s

          @logger.debug("Pre-signed URL: #{presigned_url}")

          return presigned_url
      end
    end
  end
end
