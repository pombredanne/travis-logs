module Travis
  module Logs
    class Handler
      class Instrument < Travis::Notification::Instrument
        def handle_completed
          publish(msg: "data: #{target.data}")
        end
      end
    end
  end
end
