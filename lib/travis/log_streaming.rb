require 'travis'
require 'travis/support'
require 'travis/log_streaming/app'
require 'logger'
require 'metriks'
require 'metriks/reporter/logger'
require 'multi_json'
require 'core_ext/module/load_constants'
require 'sidekiq'

$stdout.sync = true


require 'travis/task'

# TODO why the hell does the setter below not work
module Travis
  class Task
    class << self
      def run_local?
        true
      end
    end
  end
end

module Travis
  module LogStreaming
    class << self
      def preload_constants
        [Travis::LogStreaming, Travis].each do |target|
          target.load_constants!(skip: [/::AssociationCollection$/, /::Amqp/])
        end
      end

      def setup
        preload_constants
        
        Travis::Async.enabled = true
        Travis::Task.run_local = true # don't pipe log updates through travis_tasks
        # Travis::Async::Sidekiq.setup(Travis.config.redis.url, Travis.config.sidekiq)

        Travis::Features.start
        Travis::Database.connect
        Travis::Exceptions::Reporter.start
        Travis::Notification.setup
        Travis::Addons.register

        Travis::LogSubscriber::ActiveRecordMetrics.attach

        Travis::Memory.new(:logs).report_periodically if Travis.env == 'production'

        NewRelic.start if File.exists?('config/newrelic.yml')
        
        puts ActiveRecord::Base.configurations.inspect
      end
      

      def connect
        # empty for now
      end

      def disconnect
        # empty for now
      end
    end
  end
end
