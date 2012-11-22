require 'celluloid'

module Travis
  module Logs
    class Handler
      autoload :Instrument, 'travis/logs/handler/instrument'
      autoload :Pool,       'travis/logs/handler/pool'

      extend Travis::Instrumentation
      include Celluloid

      attr_reader :data

      def handle(data)
        @data = data
        Travis.uuid = data[:uuid]
        Travis.run_service(:logs_append, data: data)
      end
      instrument :handle

      Instrument.attach_to(self)
    end
  end
end
