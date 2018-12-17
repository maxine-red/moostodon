# frozen_string_literal: true

module Mastodon
  class Field < Mastodon::Base
    # @!attribute [r] name
    #   @return [String]
    # @!attribute [r] value
    #   @return [String]
    # @!attribute [r] verified_at
    #   @return [String]

    normal_attr_reader :name, :value, :verified_at
  end
end
