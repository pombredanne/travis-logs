ENV['RAILS_ENV'] ||= 'test'

require 'travis/logs/app'
require 'travis/testing/matchers'
require 'mocha'

include Mocha::API

RSpec.configure do |c|
  c.mock_with :mocha

  c.after :each do
    Travis.config.notifications.clear
  end
end

