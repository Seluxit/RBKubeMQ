module RBKubeMQ
  class Streamer
    include Check

    def initialize(client:, client_id: nil, channel: nil, meta: nil, store: false)
      is_class?(client, [RBKubeMQ::Client], "client")
      @client = client
      @client_id  = client_id
      @channel = channel
      @meta    = meta.nil? ? meta.to_s : meta
      @store = store
    end

    attr_accessor :client_id, :channel, :meta, :store

    def start
      @ws = Faye::WebSocket::Client.new("#{@client.ws}/send/stream")
      @ws
    end

    def send(message, meta: @meta, store: @store, client_id: @client_id,
        channel: @channel, id: nil)
      body = {
        "EventID" => id,
        "ClientID" => client_id,
        "Channel" => channel,
        "Metadata" => meta,
        "Body" => message,
        "Store" => store
      }
      @ws.send(RBKubeMQ::Utility.dump(body))
    rescue StandardError => e
      raise RBKubeMQ::Error.new(e.message)
    end
  end
end
