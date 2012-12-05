require 'sinatra'
require 'travis/support/logging'
require 'newrelic_rpm'

module Travis
  module LogStreaming
    class App < Sinatra::Base
      include Logging

      # use Rack::CommonLogger for request logging
      enable :logging, :dump_errors

      # Used for new relic uptime monitoring
      get '/uptime' do
        200
      end

      # the main endpoint for scm services
      post '/append' do
        Travis.uuid = params['uuid']
        Travis.run_service(:logs_append, data: params)
        204
      end

      protected

      def credentials
        worker, token = Rack::Auth::Basic::Request.new(env).credentials
        { :worker => worker, :token => token }
      end
    end
  end
end
