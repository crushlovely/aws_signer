require 'aws_signer/configuration'
require 'aws_signer/signature'
require 'aws_signer/version'

require 'base64'
require 'openssl'
require 'active_support/core_ext/object/to_query'
require 'hashie'

module AwsSigner
  extend Configuration

  class << self
    # Public: Create a signature using the options passed in.
    #
    # options - The Hash options used to create the signature (default: {}):
    #           :file_name  - The String file name of the file being uploaded (required).
    #           :mime_type  - The String mime type of the file being uploaded (required).
    #           :request_expiration - The Integer number of minute to expire the signature in (optional, default: 5).
    #           :headers - The String headers for the signature (optional, default: 'x-amz-acl:public-read').
    #           :base_file_path - The String base file path to upload the file to (optional, default: a path containing
    #                             the current timestamp and a random string,
    #                             e.g. 2014/07/31/02/12/debd6f2fcb1b5cb160fce9c9909aebf2).
    #
    # Examples:
    #
    #   AwsSigner.signature(:file_name => 'image.gif', :mime_type => 'image/gif')
    #   # => <AwsSigner::Signature>
    #
    # Returns an AwsSigner::Signature object.
    def signature(options = {})
      Signature.new(options)
    end
  end

  class RequiredConfigurationError < StandardError
    # Internal
    def initialize(required_attribute)
      super("Missing required configuration for '#{required_attribute}'")
    end
  end
end
