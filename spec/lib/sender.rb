require_relative "../spec_helper"
YOUR_HOST = "10.109.85.157"

describe "Sender" do
  context "The User" do
    before(:all) do
  		@client = RBKubeMQ::Client.new host: YOUR_HOST
  		@sender = @client.sender(client_id: :client, channel: :channel)
  	end

    it "can send a request" do
      response = @sender.event("TEST")
      expect(response.code).to eq 200
      expect(response.body["is_error"]).to eq false
    end

    it "can receive the message" do
      puts ""
      @message = nil
      Thread.new do
        EM.run do
          subscriber = @client.subscriber(client_id: :client,
            channel: :channel, group: :test).events
          subscriber.on :open do |event|
            puts "open"
          end
          subscriber.on :message do |event|
            @message = RBKubeMQ::Utility.load(event.data)
            EM.stop
          end
          subscriber.on :close do |event|
            puts "closed"
          end
        end
      end
      sleep(0.5)
      response = @sender.event("TEST")
      expect(response.code).to eq 200
      while(@message.nil?) do; end
      expect(@message["Body"]).to eq "TEST"
    end

    it "can open a stream to send messages" do
      sleep(1)
      puts ""
      @subscriber = []
      @streamer = []
      @end_subscriber = false
      @end_streamer = false
      @i = 0
      Thread.new(@subscriber) do |subs|
        EM.run do
          subscriber = @client.subscriber(client_id: :client,
            channel: :channel, group: :test).events
          subscriber.on :open do |event|
            puts "open_subscriber"
          end
          subscriber.on :message do |event|
            puts "message_received"
            subs << RBKubeMQ::Utility.load(event.data)
            if subs.size == 3
              @end_subscriber = true
            end
          end
          subscriber.on :close do |event|
            puts "closed_subscriber"
          end
        end
      end
      sleep(0.5)
      Thread.new(@streamer) do |stre|
        EM.run do
          streamer = @client.streamer(client_id: :client, channel: :channel)
          ws = streamer.start
          ws.on :open do |event|
            puts "open_streamer"
          end
          ws.on :message do |event|
            puts "message_sent"
            stre << RBKubeMQ::Utility.load(event.data)
            if stre.size == 3
              @end_streamer = true
            end
          end
          ws.on :close do |event|
            puts "closed_streamer"
          end
          timer = EM::PeriodicTimer.new(0.1) do
            @i += 1
            puts "sending #{@i}"
            streamer.send(@i)
          end
        end
      end

      while(!@end_subscriber) do; end
      while(!@end_streamer) do; end
      EM.stop

      expect(@subscriber[0]["Body"]).to eq "1"
      expect(@streamer[0]["Sent"]).to eq true
    end

    it "can send a request and receive an answer" do
      sleep(1)
      puts ""
      Thread.new do
        EM.run do
          subscriber = @client.subscriber(client_id: :client,
            channel: :channel, group: :test).requests
          subscriber.on :open do |event|
            puts "open"
          end
          subscriber.on :message do |event|
            puts "answering"
            response = @sender.response(event.data)
            EM.stop
          end
          subscriber.on :close do |event|
            puts "closed"
          end
        end
      end
      sleep(0.5)
      puts "asking"
      response = @sender.request("ASKING", timeout: 5000)
      expect(response.code).to eq 200
      expect(response.body["data"]["Executed"]).to eq true
    end

    it "can send a query and receive an answer" do
      sleep(1)
      puts ""
      Thread.new do
        EM.run do
          subscriber = @client.subscriber(client_id: :client,
            channel: :channel, group: :test).queries
          subscriber.on :open do |event|
            puts "open"
          end
          subscriber.on :message do |event|
            puts "answering"
            response = @sender.response(event.data, message: "ANSWERED")
            EM.stop
          end
          subscriber.on :close do |event|
            puts "closed"
          end
        end
      end
      sleep(0.5)
      puts "asking"
      response = @sender.query("ASKING", timeout: 5000)
      expect(response.code).to eq 200
      expect(response.body["data"]["Body"]).to eq "ANSWERED"
    end
  end
end
