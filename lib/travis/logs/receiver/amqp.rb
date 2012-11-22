module Travis
  module Logs
    module Receiver
      class Amqp
        include Travis::Logging

        attr_reader :handler

        def initialize(&handler)
          @handler = handler
        end

        def start
          info 'Subscribing to amqp ...'
          info "Subscribing to reporting.jobs.logs"
          Travis::Amqp::Consumer.jobs('logs').subscribe(ack: true, &method(:receive))
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

