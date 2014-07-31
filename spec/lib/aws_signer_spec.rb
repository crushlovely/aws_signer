require 'spec_helper'

describe AwsSigner do
  describe '.signature' do
    before { configure! }

    it 'returns an instance of AwsSigner::Signature' do
      expect(AwsSigner.signature(:file_name => 'image.jpg', :mime_type => 'image/jpg')).to be_an(AwsSigner::Signature)
    end
  end
end
