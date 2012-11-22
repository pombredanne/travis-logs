require 'multi_json'

require 'travis'
require 'travis/logs/handler'
require 'travis/logs/handler'
require 'timeout'
require 'active_support/core_ext/hash/keys'

module Travis
  module Logs
    autoload :Handler,  'travis/logs/handler'
    autoload :Receiver, 'travis/logs/receiver'

    class App
      extend Exceptions::Handling
      include Travis::Logging

      attr_reader :receivers, :handlers, :options

      def initialize(options = {})
        @receivers = Array(options[:receivers] || :amqp).map do |type|
          Receiver.for(type).new(&method(:handle))
        end
        @handlers = Handler::Pool.new(options[:shards] || 10)
        @options = options
      end

      def start
        receivers.each(&:start)
      end

      def handle(payload)
        timeout do
          return unless payload = decode(payload)
          shard = payload[:id].to_i % handlers.size
          handlers[shard].async.handle(payload)
        end
      end
      rescues :handle, from: Exception unless Travis.env == 'test'

      private

        def timeout(&block)
          Timeout::timeout(options[:timeout] || 60, &block)
        end

        def decode(payload)
          MultiJson.decode(payload).symbolize_keys
        rescue StandardError => e
          error "[#{Thread.current.object_id}] [decode error] payload could not be decoded with engine #{MultiJson.engine.to_s} (#{e.message}): #{payload.inspect}"
          nil
        end
    end
  end
end
