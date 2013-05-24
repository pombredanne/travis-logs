require 'travis'
require 'core_ext/module/load_constants'
require 'timeout'
require 'travis/logs/receive/queue'

$stdout.sync = true

module Travis
  module Logs
    class Receive
      def setup
        Travis::Async.enabled = true
        Travis::Amqp.config = Travis.config.amqp
        Travis::Addons::Pusher::Task.run_local = true # don't pipe log updates through travis_tasks

        Travis::Database.connect
        Travis::Exceptions::Reporter.start
        Travis::Notification.setup
        Travis::Addons.register

        Travis::LogSubscriber::ActiveRecordMetrics.attach
        Travis::Memory.new(:logs).report_periodically if Travis.env == 'production'
      end

      def run
        1.upto(Travis.config.logs.threads || 10).each do
          Queue.subscribe('logs', &method(:receive))
        end
      end

      def receive(payload)
        with_connection_and_cache do
          Travis.run_service(:logs_receive, data: payload)
        end
      end

      def with_connection_and_cache
        ActiveRecord::Base.connection_pool.with_connection do
          ActiveRecord::Base.cache do
            yield
          end
        end
      end
    end
  end
end
