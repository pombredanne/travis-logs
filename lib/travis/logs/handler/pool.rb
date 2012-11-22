module Travis
  module Logs
    class Handler
      class Pool
        attr_reader :size

        def initialize(size)
          @size = size

          0.upto(size - 1) do |number|
            Handler.supervise_as :"shard_#{number}"
          end
        end

        def [](number)
          Celluloid::Actor[:"shard_#{number}"]
        end
      end
    end
  end
end
