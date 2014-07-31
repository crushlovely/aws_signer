require 'spec_helper'

describe AwsSigner::Signature do
  let(:file_name) { 'keyboard_cat.gif' }
  let(:mime_type) { 'image/gif' }
  let(:local_time) { Time.local(2008, 9, 1, 12, 0, 0).utc }
  let(:secure_random_string) { 'c1c9d98871b8d9a6308ff0a5b6e69ff8' }
  let(:base64_string) { 'faba3f38e1f19793e531c5c94ef6b399acb38890cea42c6448' }
  let(:hmac_digest_string) { '73cbfa693a5960187625ca70e148a9526b54f92376befdffcc' }

  before do
    Timecop.freeze(local_time)
    allow(SecureRandom).to receive(:hex).and_return(secure_random_string)
    allow(Base64).to receive(:strict_encode64).and_return(base64_string)
    allow(OpenSSL::HMAC).to receive(:digest).and_return(hmac_digest_string)
  end

  describe 'initialization' do
    subject { described_class.new(:file_name => file_name, :mime_type => mime_type) }

    context 'when the library has not been properly configured' do
      it 'raises an exception' do
        expect { subject }
          .to raise_error { AwsSigner::RequiredConfigurationError }
      end
    end

    context 'when the library has been properly configured' do
      before { configure! }

      it 'sets the file_name' do
        expect(subject.options.file_name).to eq(file_name)
      end

      it 'sets the mime_type' do
        expect(subject.options.mime_type).to eq(mime_type)
      end
    end
  end

  shared_examples 'a method returning the public url' do
    it { should include(AwsSigner.s3_base_url) }
    it { should include(AwsSigner.upload_bucket) }
    it { should include(local_time.strftime('%Y/%m/%d/%H/%M')) }
    it { should include(secure_random_string) }
    it { should include(file_name) }
  end

  describe '#public_url' do
    subject { described_class.new(:file_name => file_name, :mime_type => mime_type).public_url }
    before { configure! }

    it_behaves_like 'a method returning the public url'
  end

  describe '#signed_url' do
    subject { described_class.new(:file_name => file_name, :mime_type => mime_type).signed_url }
    before { configure! }
    it_behaves_like 'a method returning the public url'
  end

  describe '#signed_url_params' do
    let(:signer) { described_class.new(:file_name => file_name, :mime_type => mime_type) }
    let(:mock_signing_string) { 'fake' }

    subject { signer.signed_url_params }

    before do
      configure!
      allow(signer).to receive(:signing_string).and_return(mock_signing_string)
    end

    it 'should digest the signing string' do
      expect(OpenSSL::HMAC).to receive(:digest).with('sha1', AwsSigner.secret_access_key, mock_signing_string)
      subject
    end

    it 'should base64 encode the digest' do
      expect(Base64).to receive(:strict_encode64).with(hmac_digest_string)
      subject
    end

    it 'contains the AWSAccessKeyId' do
      expect(subject).to have_key('AWSAccessKeyId')
      expect(subject['AWSAccessKeyId']).to eq(AwsSigner.access_key_id)
    end

    it 'contains the Expires' do
      expect(subject).to have_key('Expires')
      expect(subject['Expires']).to eq(signer.expiration)
    end

    it 'contains the Signature' do
      expect(subject).to have_key('Signature')
      expect(subject['Signature']).to eq(base64_string)
    end
  end
end
