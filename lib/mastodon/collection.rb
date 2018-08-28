# frozen_string_literal: true

module Mastodon
  # Mastodon collections. Used in place of arrays.
  class Collection
    include ::Enumerable

    def initialize(items, klass)
      @collection = items.map { |attributes| klass.new(attributes) }
    end

    def each(start = 0)
      return to_enum(:each, start) unless block_given?

      Array(@collection[start..-1]).each do |element|
        yield(element)
      end

      self
    end

    def size
      @collection.size
    end

    def last
      @collection.last
    end
  end
end
