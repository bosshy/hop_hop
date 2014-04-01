module HopHop
  #set HopHop::Consumer.receiver=HopHop::TestReceiver.new
  #then setup your consumer:
  #TestConsumer.consume
  #fire an event at will: TestConsumer.receiver.receive_event({:foo => :bar},{:timestamp => Time.now.to_i})
  class TestReceiver
    def consume(consumer)
      @consumer=consumer
    end

    def receive_event(data, meta={}, context=nil)
      meta[:headers]||={}
      meta[:headers][:producer] ||= "test_producer"
      meta[:headers][:version] ||= 1
      meta[:timestamp] ||= Time.now.to_i
      meta[:routing_key] ||= "test.test"

      event=HopHop::ConsumeEvent.new(data, meta, context)
      info=HopHop::QueueInfo.new(3,4)
      @consumer.consume(event,info)
    end
  end
end
