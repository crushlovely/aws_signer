module AwsSigner
  module Configuration
    REQUIRED_ATTRIBUTES = [:upload_bucket, :secret_access_key, :access_key_id]
    # Default S3 Base URL
    DEFAULT_S3_BASE_URL = 'https://s3.amazonaws.com'

    # S3 Base URL
    attr_writer :s3_base_url

    # Bucket to upload to
    attr_accessor :upload_bucket

    # AWS Secret Access Key
    attr_accessor :secret_access_key

    # AWS Access Key ID
    attr_accessor :access_key_id

    # Public: Configuration object.
    #
    # Example:
    #
    #   AwsSigner.configure do |configuration|
    #     configuration.upload_bucket = 'my-bucket'
    #     configuration.secret_access_key = 'SECRET'
    #     configuration.access_key_id = 'SECRET'
    #   end
    #
    # Yields self to be able to configure AwsSigner with block-style configuration.
    def configure
      yield self
    end

    # Public: The S3 base url.
    def s3_base_url
      @s3_base_url ||= DEFAULT_S3_BASE_URL
    end

    # Public: Validate that all required configuration is present.
    def validate_configuration!
      REQUIRED_ATTRIBUTES.any? do |required_attribute|
        required = send(required_attribute)
        fail AwsSigner::RequiredConfigurationError, required_attribute if required.nil? || required.empty?
      end
    end
  end
end
