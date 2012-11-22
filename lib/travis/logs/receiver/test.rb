module Travis
  module Logs
    module Receiver
      class Test
        attr_reader :options, :handler

        def initialize(options, &handler)
          @options = options
          @handler = handler
        end

        def receive(message, payload)
          handler.call(payload)
        end
      end
    end
  end
end
