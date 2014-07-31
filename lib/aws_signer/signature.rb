module AwsSigner
  class Signature
    REQUIRED_OPTIONS = [:file_name, :mime_type]

    attr_reader :options

    # Public: Initialize a Signature object.
    def initialize(options = {})
      AwsSigner.validate_configuration!
      @options = Hashie::Mash.new(default_options.merge(options))
      validate_options!
    end

    # Public: The public url for the file being uploaded
    #
    # Returns the url as a String.
    def public_url
      "#{AwsSigner.s3_base_url}/#{AwsSigner.upload_bucket}/#{file_path}"
    end

    # Public: The signed url for the file being uploaded.
    # This includes the public url as well as all required
    # signature parameters.
    #
    # Returns the signed url as a String.
    def signed_url
      [public_url, signed_url_params.to_query].join('?')
    end

    # Public: The signed url parameters.
    #
    # Returns a Hash of required parameters for signing
    # the public url.
    def signed_url_params
      {
        'AWSAccessKeyId' => AwsSigner.access_key_id,
        'Expires' => expiration,
        'Signature' => base64_encoded_signature
      }
    end

    # Public: The expiration of the signing request.
    #
    # Returns a timestamp in Integer format (in seconds).
    def expiration
      @expiration ||= Time.now.to_i + (60 * options.request_expiration)
    end

    # Public: The JSON representation of this object.
    #
    # Returns a Hash containing the public and signed urls
    # that can be serialized into JSON.
    def to_json
      {
        :public_url => public_url,
        :signed_url => signed_url
      }
    end

    private

    def default_options
      {
        :request_expiration => 5,
        :base_file_path => [Time.now.utc.strftime('%Y/%m/%d/%H/%M'), SecureRandom.hex].join('/'),
        :headers => 'x-amz-acl:public-read'
      }
    end

    def validate_options!
      REQUIRED_OPTIONS.any? do |required_option|
        fail AwsSigner::RequiredConfigurationError, required_option unless options.send("#{required_option}?")
      end
    end

    def sanitized_file_name
      options.file_name.gsub(/[^\w\.\-]/, '_')
    end

    def base64_encoded_signature
      Base64.strict_encode64(hmac_digest_signature)
    end

    def hmac_digest_signature
      OpenSSL::HMAC.digest('sha1', AwsSigner.secret_access_key, signing_string)
    end

    def signing_string
      "PUT\n\n#{options.mime_type}\n#{expiration}\n#{options.headers}\n/#{AwsSigner.upload_bucket}/#{file_path}"
    end

    def file_path
      @file_path ||= [options.base_file_path, sanitized_file_name].join('/')
    end
  end
end
