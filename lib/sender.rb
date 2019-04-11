module RBKubeMQ
  class Sender
    include Check
    @@response = Struct.new(:code, :body)

    HEADER = {"Content-Type" => "application/json"}

    def initialize(client:, client_id: nil, channel: nil, meta: nil, store: false,
      timeout: 5000, cache_key: nil, cache_ttl: nil)
      is_class?(client, [RBKubeMQ::Client], "client")
      @client     = client
      @client_id  = client_id
      @channel    = channel
      @meta       = meta.nil? ? meta : meta.to_s
      @store      = store
      @timeout    = timeout
      @cache_key   = cache_key
      @cache_ttl   = cache_ttl
    end

    def event(message, meta: @meta, store: @store, client_id: @client_id,
        channel: @channel, id: nil)
      body = {
        "EventID" => id,
        "ClientID" => client_id,
        "Channel" => channel,
        "Metadata" => meta,
        "Body" => message,
        "Store" => store
      }
      http = HTTParty.post("#{@client.uri}/send/event", headers: HEADER,
        body: RBKubeMQ::Utility.dump(body))
      @@response.new(http.code, RBKubeMQ::Utility.load(http.parsed_response))
    rescue StandardError => e
      raise RBKubeMQ::Error.new(e.message)
    end

    def request(message, meta: @meta, store: @store, client_id: @client_id,
        channel: @channel, id: nil, timeout: @timeout)
      body = {
        "RequestID" => id,
        "RequestTypeData" => 1,
        "ClientID" => client_id,
        "Channel" => channel,
        "Metadata" => meta,
        "Body" => message,
        "Timeout" => timeout
      }
      http = HTTParty.post("#{@client.uri}/send/request", headers: HEADER,
        body: RBKubeMQ::Utility.dump(body))
      @@response.new(http.code, RBKubeMQ::Utility.load(http.parsed_response))
    rescue StandardError => e
      raise RBKubeMQ::Error.new(e.message)
    end

    def query(message, meta: @meta, store: @store, client_id: @client_id,
        channel: @channel, id: nil, timeout: @timeout, cache_key: @cache_key,
        cache_ttl: @cache_ttl)
      body = {
        "RequestID" => id,
        "RequestTypeData" => 2,
        "ClientID" => client_id,
        "Channel" => channel,
        "Metadata" => meta,
        "Body" => message,
        "Timeout" => timeout,
        "CacheKey" => cache_key,
        "CacheTTL" => cache_ttl
      }
      http = HTTParty.post("#{@client.uri}/send/request", headers: HEADER,
        body: RBKubeMQ::Utility.dump(body))
      @@response.new(http.code, RBKubeMQ::Utility.load(http.parsed_response))
    rescue StandardError => e
      raise RBKubeMQ::Error.new(e.message)
    end

    def response(request, message: nil, executed: true, error: nil, meta: @meta,
      client_id: @client_id)
      unless request.is_a?(Hash)
        request = RBKubeMQ::Utility.load(request)
      end

      body = {
        "RequestID" => request["RequestID"],
        "ClientID" => client_id,
        "ReplyChannel" => request["ReplyChannel"],
        "Executed" => executed,
        "Error" => error
      }
      if request["RequestTypeData"] == 2
        body["Metadata"] = meta
        body["Body"] = message
      end

      http = HTTParty.post("#{@client.uri}/send/response", headers: HEADER,
        body: RBKubeMQ::Utility.dump(body))
      @@response.new(http.code, RBKubeMQ::Utility.load(http.parsed_response))
    rescue StandardError => e
      raise RBKubeMQ::Error.new(e.message)
    end
  end
end
