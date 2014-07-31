require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rspec'
require 'aws_signer'
require 'timecop'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:each) do
    AwsSigner.upload_bucket = nil
    AwsSigner.secret_access_key = nil
    AwsSigner.access_key_id = nil
  end
end

def configure!
  AwsSigner.configure do |configuration|
    configuration.upload_bucket = 'my-bucket'
    configuration.secret_access_key = 'SECRETACCESSKEY'
    configuration.access_key_id = 'ACCESSKEYID'
  end
end
