# AwsSigner for Ruby

A gem to help with creating signed URLs for uploading files direct to S3.

## Installation

`gem install aws_signer`

or in your `Gemfile`

```ruby
gem 'aws_signer'
```

## Usage

Make sure you require the library.

```ruby
require 'aws_signer'
```

### Configuration

You will need to setup a few configuration options before using the library:

``` ruby
AwsSigner.configure do |configuration|
  # The S3 bucket you want to upload to
  configuration.upload_bucket = 'my-bucket'
  # Your AWS Secret Access Key
  configuration.secret_access_key = 'SECRETACCESSKEY'
  # Your Access Key ID
  configuration.access_key_id = 'ACCESSKEYID'
end
```

### Creating Signed URLs

Created a signed URL is as easy as passing in a file name and a mime type:

``` ruby
signer = AwsSigner.signature(:file_name => 'image.jpg', :mime_type => 'image/jpg')
# Return the public URL for the file.
signer.public_url
# Return the signed URL for the file.
signer.signed_url
```

The object returned responds to `#to_json`, so you can use it in a Rails controller like so:

``` ruby
class AwsSignaturesController < ApplicationController
  def create
    signer = AwsSigner.signature(signature_parameters)
    render :json => signer, :status => 201
  end

  protected

  def signature_parameters
    params.require(:file_name)
    params.require(:mime_type)
    params
  end
end
```

That controller action would return a JSON payload that looks something like this:

``` json
{
    "public_url": "https://s3.amazonaws.com/my-bucket/2014/07/31/03/04/42c842de85749a1723c98ca2932a3b6a/image.jpg",
    "signed_url": "https://s3.amazonaws.com/my-bucket/2014/07/31/03/04/42c842de85749a1723c98ca2932a3b6a/image.jpg?AWSAccessKeyId=ACCESSKEYID&Expires=1406776178&Signature=77DZuYVRYqZHjw9zqwipBiZrmUY%3D"
}
```

## Contributing to aws_signer

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so we don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so we can cherry-pick around it.

## Copyright

Copyright (c) 2014 PJ Kelly (Crush & Lovely). See LICENSE for further details.
