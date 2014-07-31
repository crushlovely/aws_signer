require 'spec_helper'

describe AwsSigner::Configuration do
  describe '.configure' do
    it 'should have default attributes' do
      AwsSigner.configure do |configuration|
        expect(configuration.s3_base_url).to eq(AwsSigner::Configuration::DEFAULT_S3_BASE_URL)
        expect(configuration.upload_bucket).to be_nil
        expect(configuration.secret_access_key).to be_nil
        expect(configuration.access_key_id).to be_nil
      end
    end
  end

  describe '.validate_configuration!' do
    before do
      AwsSigner.configure do |configuration|
        configuration.upload_bucket = 'fake'
        configuration.secret_access_key = 'fake'
        configuration.access_key_id = 'fake'
      end
    end

    AwsSigner::Configuration::REQUIRED_ATTRIBUTES.each do |required_attribute|
      context "when '#{required_attribute}' is not set" do
        before { AwsSigner.send("#{required_attribute}=", nil) }

        it 'raises an exception' do
          expect { AwsSigner.validate_configuration! }
            .to raise_error { AwsSigner::RequiredConfigurationError.new(required_attribute) }
        end
      end
    end
  end
end
