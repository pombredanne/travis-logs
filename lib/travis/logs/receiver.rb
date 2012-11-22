require 'active_support/core_ext/string/inflections'

module Travis
  module Logs
    module Receiver
      autoload :Amqp, 'travis/logs/receiver/amqp'
      autoload :Test, 'travis/logs/receiver/test'

      class << self
        def for(type)
          const_get(type.to_s.camelize)
        end
      end
    end
  end
end

