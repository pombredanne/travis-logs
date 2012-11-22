module Travis
  module Logs
    module Receiver
      class Amqp
        include Travis::Logging

        attr_reader :options, :handler

        def initialize(options, &handler)
          @options = options
          @handler = handler
        end

        def start
          info 'Subscribing to amqp ...'
          info "Subscribing to reporting.jobs.logs"
          logs = Travis::Amqp::Consumer.jobs('logs')
          logs.subscribe(prefetch: options[:shards], ack: true, &method(:receive))
        end

        def receive(message, payload)
          handler.call(payload)
        rescue Exception => e
          puts "!!!FAILSAFE!!! #{e.message}", e.backtrace
        ensure
          message.ack
        end
      end
    end
  end
end

