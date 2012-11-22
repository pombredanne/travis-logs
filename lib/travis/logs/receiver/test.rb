module Travis
  module Logs
    module Receiver
      class Test
        attr_reader :handler

        def intialize(handler)
          @handler = handler
        end

        def receive(message, payload)
          handler.call(payload)
        end
      end
    end
  end
end
