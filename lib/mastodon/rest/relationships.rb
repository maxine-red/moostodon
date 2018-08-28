# frozen_string_literal: true

require 'mastodon/rest/utils'
require 'mastodon/relationship'

module Mastodon
  module REST
    module Relationships
      include Mastodon::REST::Utils

      # Get the relationships of authenticated user towards given other users
      # @param ids [Integer]
      # @return [Mastodon::Collection<Mastodon::Relationship>]
      def relationships(*ids)
        perform_request_with_collection(:get, '/api/v1/accounts/relationships',
                                        array_param(:id, ids),
                                        Mastodon::Relationship)
      end

      # Follow a user
      # @param id [Integer]
      # @return [Mastodon::Relationship]
      def follow(id)
        perform_request_with_object(:post, "/api/v1/accounts/#{id}/follow",
                                    {}, Mastodon::Relationship)
      end

      # Follow a remote user
      # @param uri [String] username@domain of the person you want to follow
      # @return [Mastodon::Account]
      def remote_follow(uri)
        perform_request_with_object(:post, '/api/v1/follows', { uri: uri },
                                    Mastodon::Account)
      end

      # Unfollow a user
      # @param id [Integer]
      # @return [Mastodon::Relationship]
      def unfollow(id)
        perform_request_with_object(:post, "/api/v1/accounts/#{id}/unfollow",
                                    {}, Mastodon::Relationship)
      end

      # Block a user
      # @param id [Integer]
      # @return [Mastodon::Relationship]
      def block(id)
        perform_request_with_object(:post, "/api/v1/accounts/#{id}/block",
                                    {}, Mastodon::Relationship)
      end

      # Unblock a user
      # @param id [Integer]
      # @return [Mastodon::Relationship]
      def unblock(id)
        perform_request_with_object(:post, "/api/v1/accounts/#{id}/unblock",
                                    {}, Mastodon::Relationship)
      end

      # Mute a user
      # @param id [Integer]
      # @return [Mastodon::Relationship]
      def mute(id)
        perform_request_with_object(:post, "/api/v1/accounts/#{id}/mute",
                                    {}, Mastodon::Relationship)
      end

      # Unmute a user
      # @param id [Integer]
      # @return [Mastodon::Relationship]
      def unmute(id)
        perform_request_with_object(:post, "/api/v1/accounts/#{id}/unmute",
                                    {}, Mastodon::Relationship)
      end
    end
  end
end
