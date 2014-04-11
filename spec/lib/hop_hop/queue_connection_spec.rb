require 'spec_helper'
require 'json'

describe HopHop::QueueConnection, :rabbitmq do
  after(:all) do
    HopHop::Event.sender = HopHop::TestSender.new
  end

  class TestConsumer < HopHop::Consumer
    bind "test.queue_connector_test"
    queue "test_queue_test"

    def consume(event,info)
      raise 'foo'
      # if event.data[:error]
      #   raise 'whatever'
      # else
      #   exit_loop
      # end
    end
    def on_error(*args)
      :ignore
    end
  end
  class TestEvent < HopHop::Event
    private
    def subsystem
      "test"
    end
  end

  before(:each) do
    HopHop::Event.sender = HopHop::BunnySender.new
    described_class.any_instance.stub(:logger).and_return(double.as_null_object)
    @qc=described_class.new(consumer.new, :host => 'localhost', :port => 5672, :requeue_sleep => 0)
    @qc.stub(:exit_loop?).and_return(true) # always exit the loop after an event

    # put a message in the queue
    TestEvent.send('queue_connector_test', 1, {:error => true})
    sleep(0.2)#lets wait a bit for the message to arrive in the queue
  end
  after(:each) do
    #reestablish connection to queue and purge it before moving on
    qc=described_class.new(consumer.new, :host => 'localhost', :port => 5672)
    qc.queue.purge
    qc.close
  end


#------------------------------------------------------------------------------#
#------------------------------ specs start here ------------------------------#
#------------------------------------------------------------------------------#


  context "error handling" do
    context "on error => ignore" do
      let(:consumer) {
        Class.new(TestConsumer) do
          def on_error(*args)
            :ignore
          end
        end
      }

      it "should acknowledge the message" do
        expect(@qc).to receive(:acknowledge_message)
        @qc.loop
      end
      it "should not requeue the message" do
        expect(@qc).to_not receive(:requeue_message)
        @qc.loop
      end
      it "should exit normally" do
        expect(@qc.loop).to be_true
      end
      it "should not stop the loop" do
        expect(@qc).to_not receive(:exit_loop!)
        @qc.loop
      end
    end

    context "on error -> exit" do
      let(:consumer) {
        Class.new(TestConsumer) do
          def on_error(*args)
            :exit
          end
        end
      }

      it "should not acknowledge the message" do
        expect(@qc).to_not receive(:acknowledge_message)
        @qc.loop
      end
      it "should requeue the message" do
        expect(@qc).to receive(:requeue_message)
        @qc.loop
      end
      it "should not exit normally" do
        expect(@qc.loop).to be_false
      end
      it "should stop the loop" do
        expect(@qc).to receive(:exit_loop!)
        @qc.loop
      end
    end

    context "on error -> requeue" do
      let(:consumer) {
        Class.new(TestConsumer) do
          def on_error(*args)
            :requeue
          end
        end
      }

      it "should not acknowledge the message" do
        expect(@qc).to_not receive(:acknowledge_message)
        @qc.loop
      end
      it "should requeue the message" do
        expect(@qc).to receive(:requeue_message)
        @qc.loop
      end
      it "should exit normally" do
        expect(@qc.loop).to be_true
      end
      it "should not stop the loop" do
        expect(@qc).to_not receive(:exit_loop!)
        @qc.loop
      end
    end

    context "on error -> unknown" do
      let(:consumer) {
        Class.new(TestConsumer) do
          def on_error(*args)
            :wtf # something not defined...
          end
        end
      }

      it "should not acknowledge the message" do
        expect(@qc).to_not receive(:acknowledge_message)
        @qc.loop
      end
      it "should requeue the message" do
        expect(@qc).to receive(:requeue_message)
        @qc.loop
      end
      it "should not exit normally" do
        expect(@qc.loop).to be_false
      end
      it "should stop the loop" do
        expect(@qc).to receive(:exit_loop!)
        @qc.loop
      end
    end

  end
end