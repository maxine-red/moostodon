# frozen_string_literal: true

require 'spec_helper'

describe Mastodon::REST::Media do
  before do
    @client = Mastodon::REST::Client.new(base_url: 'https://mastodon.social', bearer_token: '123456')
    stub_request(:post, 'https://mastodon.social/api/v1/media').to_return(fixture('media.json'))
  end

  describe '#upload_media' do
    it 'works with a File' do
      path = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'upload.png')
      media = @client.upload_media(File.new(path))
      expect(media).to be_a Mastodon::Media
    end

    it 'works with a description' do
      path = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'upload.png')
      expect(@client).to receive(:perform_request_with_object).with(anything, anything, hash_including(description: 'Lorem ipsum'), anything)
      @client.upload_media(File.new(path), 'Lorem ipsum')
    end

    it 'works with a StringIO' do
      media = @client.upload_media(StringIO.new)
      expect(media).to be_a Mastodon::Media
    end

    it 'works with a HTTP::FormData::File' do
      path = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'upload.png')
      f = HTTP::FormData::File.new(path)
      media = @client.upload_media(f)
      expect(media).to be_a Mastodon::Media
    end
  end
end
