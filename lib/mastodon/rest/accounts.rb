# frozen_string_literal: true

require_relative '../rest/utils'
require_relative '../account'

module Mastodon
  module REST
    module Accounts
      include Mastodon::REST::Utils

      # Retrieve account of authenticated user
      # @return [Mastodon::Account]
      def verify_credentials
        perform_request_with_object(:get, '/api/v1/accounts/verify_credentials',
                                    {}, Mastodon::Account)
      end

      # Update authenticated account attributes
      # @param options [Hash]
      # @option options display_name [String] The name to display in the
      #   user's profile
      # @option options note [String] A new biography for the user
      # @option options avatar [String] A base64 encoded image to display as
      #   the user's avatar
      # @option options header [String] A base64 encoded image to display as
      #   the user's header image
      # @option options fields [Array<Hash>] Array of hashes representing
      #   fields to be set
      # @return [Mastodon::Account]
      def update_credentials(opts = {})
        opts[:fields] and opts.delete(:fields).each_with_index { |f, i|
          opts["fields_attributes[#{i}][name]"] = f[:name]
          opts["fields_attributes[#{i}][value]"] = f[:value]
        }
        perform_request_with_object(:patch,
                                    '/api/v1/accounts/update_credentials',
                                    opts, Mastodon::Account)
      end

      # Retrieve account
      # @param id [Integer]
      # @return [Mastodon::Account]
      def account(id)
        perform_request_with_object(:get, "/api/v1/accounts/#{id}", {},
                                    Mastodon::Account)
      end

      # Get a list of followers
      # @param id [Integer]
      # @return [Mastodon::Collection<Mastodon::Account>]
      def followers(id)
        perform_request_with_collection(:get,
                                        "/api/v1/accounts/#{id}/followers",
                                        {}, Mastodon::Account)
      end

      # Get a list of followed accounts
      # @param id [Integer]
      # @return [Mastodon::Collection<Mastodon::Account>]
      def following(id)
        perform_request_with_collection(:get,
                                        "/api/v1/accounts/#{id}/following",
                                        {}, Mastodon::Account)
      end

      # Follow a remote user
      # @param uri [String] The URI of the remote user, in the format of
      #   username@domain
      # @return [Mastodon::Account]
      def follow_by_uri(uri)
        perform_request_with_object(:post,
                                    '/api/v1/follows', { uri: uri },
                                    Mastodon::Account)
      end

      # Gets follow requests
      # @param options [Hash]
      # @option options :limit [Integer]
      # @return [Mastodon::Collection<Mastodon::Account>]
      def follow_requests(options = {})
        perform_request_with_collection(:get, '/api/v1/follow_requests',
                                        options, Mastodon::Account)
      end

      # Accept a follow request
      # @param id [Integer]
      # @return [Boolean]
      def accept_follow_request(id)
        !perform_request(:post, "/api/v1/follow_requests/#{id}/authorize").nil?
      end

      # Reject follow request
      # @param id [Integer]
      # @return [Boolean]
      def reject_follow_request(id)
        !perform_request(:post, "/api/v1/follow_requests/#{id}/reject").nil?
      end
    end
  end
end
