# frozen_string_literal: true

require 'http/request'
require_relative '../client'
require_relative '../streaming/connection'
require_relative '../streaming/deleted_status'
require_relative '../streaming/message_parser'
require_relative '../streaming/response'

module Mastodon
  module Streaming
    # Streaming client class, to handle all streaming purposes.
    class Client < Mastodon::Client
      attr_writer :connection

      # Initializes a new Client object
      #
      # @param options [Hash] A customizable set of options.
      # @option options [String] :tcp_socket_class A class that Connection will
      #  use to create a new TCP socket.
      # @option options [String] :ssl_socket_class A class that Connection will
      #  use to create a new SSL socket.
      # @return [Mastodon::Streaming::Client]
      def initialize(options = {})
        super
        options[:using_ssl] ||= base_url =~ /^https/
        @connection = Streaming::Connection.new(options)
      end

      # Streams messages for a single user
      #
      # @yield [Mastodon::Status, Mastodon::Notification,
      # Mastodon::Streaming::DeletedStatus] A stream of Mastodon objects.
      def user(options = {}, &block)
        stream('user', options, &block)
      end

      # Streams posts from the local instance
      #
      # @yield [Mastodon::Status, Mastodon::Notification,
      # Mastodon::Streaming::DeletedStatus] A stream of Mastodon objects.
      def local(options = {}, &block)
        stream('public/local', options, &block)
      end

      # Returns statuses that contain the specified hashtag
      #
      # @yield [Mastodon::Status, Mastodon::Notification,
      # Mastodon::Streaming::DeletedStatus] A stream of Mastodon objects.
      def hashtag(tag, options = {}, &block)
        options['tag'] = tag
        stream('hashtag', options, &block)
      end

      # Returns local statuses that contain the specified hashtag
      #
      # @yield [Mastodon::Status, Mastodon::Notification,
      # Mastodon::Streaming::DeletedStatus] A stream of Mastodon objects.
      def local_hashtag(tag, options = {}, &block)
        options['tag'] = tag
        stream('hashtag/local', options, &block)
      end

      # Returns statuses from the specified list
      #
      # @yield [Mastodon::Status, Mastodon::Notification,
      # Mastodon::Streaming::DeletedStatus] A stream of Mastodon objects.
      def list(id, options = {}, &block)
        options['list'] = id
        stream('list', options, &block)
      end

      # Returns all public statuses
      #
      # @yield [Mastodon::Status, Mastodon::Notification,
      # Mastodon::Streaming::DeletedStatus] A stream of Mastodon objects.
      def firehose(options = {}, &block)
        stream('public', options, &block)
      end

      #
      # Calls an arbitrary streaming endpoint and returns the results
      # @yield [Mastodon::Status, Mastodon::Notification,
      # Mastodon::Streaming::DeletedStatus] A stream of Mastodon objects.
      def stream(path, options = {}, &block)
        request(:get, "/api/v1/streaming/#{path}", options, &block)
      end

      # Set a Proc to be run when connection established.
      def before_request(&block)
        if block_given?
          @before_request = block
          self
        elsif instance_variable_defined?(:@before_request)
          @before_request
        else
          proc {}
        end
      end

      private

      def request(method, path, params)
        before_request.call
        uri = Addressable::URI.parse(base_url + path)

        headers = Mastodon::Headers.new(self).request_headers

        request = HTTP::Request.new(verb: method,
                                    uri: "#{uri}?#{to_url_params(params)}",
                                    headers: headers)
        response = Streaming::Response.new do |type, data|
          # rubocop:disable AssignmentInCondition
          if item = Streaming::MessageParser.parse(type, data)
            yield(item)
          end
          # rubocop:enable AssignmentInCondition
        end
        @connection.stream(request, response)
      end

      def to_url_params(params)
        uri = Addressable::URI.new
        uri.query_values = params
        uri.query
      end
    end
  end
end
