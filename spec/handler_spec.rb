require 'spec_helper'

describe Travis::Logs::Handler do
  let(:handler)   { described_class.new }
  let(:payload)   { { id: 8, log: 'foo', uuid: 'uuid' } }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.last }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    Travis.stubs(:run_service)
  end

  describe 'handle' do
    it 'sets the given uuid to Travis.uuid' do
      Travis.expects(:uuid=).with('uuid')
      handler.handle(payload)
    end

    it 'runs the logs_append services' do
      Travis.expects(:run_service).with(:logs_append, data: payload)
      handler.handle(payload)
    end

    it 'is instrumented' do
      handler.handle(payload)
      event.should publish_instrumentation_event(
        event: 'travis.logs.handler.handle:completed',
        message: 'Travis::Logs::Handler#handle:completed data: {:id=>8, :log=>"foo", :uuid=>"uuid"}'
      )
    end
  end
end
