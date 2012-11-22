$stdout.sync = true

require 'travis'
require 'travis/logs/app'
require 'travis/logs/handler'
require 'travis/logs/receiver'
require 'core_ext/module/load_constants'

begin
  [Travis::Logs, Travis].each do |target|
    target.load_constants!(skip: [/::AssociationCollection$/])
  end

  Travis::Task.run_local = true # don't pipe log updates through travis_tasks
  Travis::Async.enabled = false
  Travis::Amqp.config = Travis.config.amqp

  Travis::Features.start
  Travis::Database.connect
  Travis::Exceptions::Reporter.start
  Travis::Notification.setup
  Travis::LogSubscriber::ActiveRecordMetrics.attach
  # NewRelic.start if File.exists?('config/newrelic.yml')

  Travis::Memory.new(:logs).report_periodically if Travis.env == 'production'

  app = Travis::Logs::App.new(Travis.config.logs)
  app.start
  sleep

rescue Exception => e
  puts e.message, e.backtrace
end

