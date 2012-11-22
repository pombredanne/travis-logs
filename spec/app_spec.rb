require 'spec_helper'

describe Travis::Logs::App do
  let(:app)     { described_class.new(shards: 5, timeout: 0.1, receivers: :test) }
  let(:payload) { '{ "id": 8, "log": "foo", "uuid": "uuid" }' }

  before :each do
    Travis.config.logs.stubs(:shards).returns(3)
  end

  describe 'initialize' do
    it 'sets up receivers of the given types' do
      app.receivers.map(&:class).should == [Travis::Logs::Receiver::Test]
    end

    it 'sets up a handler pool with the given size' do
      app.handlers.size.should == 5
    end
  end

  describe 'start' do
    it 'starts the receivers' do
      app.receivers.each { |r| r.expects(:start) }
      app.start
    end
  end

  describe 'handle' do
    it 'gets a handler based on the shard number' do
      app.handlers.expects(:[]).with(3).returns(stub(async: stub(handle: nil)))
      app.handle(payload)
    end

    it 'passes the decoded payload to the handler' do
      # hmmm https://github.com/celluloid/celluloid/issues/20
      # app.handlers[3].wrapped_object.expects(:handle).with(id: 8, log: 'foo', uuid: 'uuid')
      Travis.expects(:run_service).with(:logs_append, data: { id: 8, log: 'foo', uuid: 'uuid' })
      app.handle(payload)
      sleep(0.1)
    end

    it 'fails gracefully when the payload can not be decoded' do
      Travis.logger.expects(:error).with { |msg| msg.should include('[decode error]') }
      -> { app.handle('not-json') }.should_not raise_error
    end

    it 'times out after the given timeout' do
      app.handlers.stubs(:[]).with { sleep(2) }
      -> { app.handle(payload) }.should raise_error(Timeout::Error)
    end
  end
end
