module RBKubeMQ
  class Subscriber
    include Check

    def initialize(client:, client_id: nil, channel: nil, group: nil,
      events_store_type_data: 1, events_store_type_value: nil)
      is_class?(client, [RBKubeMQ::Client], "client")
      @client = client
      @client_id  = client_id
      @channel = channel
      @group = group
      @events_store_type_data = events_store_type_data
      @events_store_type_value = events_store_type_value
    end

    attr_accessor :client_id, :channel, :meta, :store, :group,
      :events_store_type_data, :events_store_type_value

    def events
      url = "#{@client.ws}/subscribe/events?client_id=#{@client_id}&channel=#{@channel}"
      url += "&group=#{@group}" unless @group.nil?
      url += "&subscribe_type=events"
      @ws = Faye::WebSocket::Client.new(url)
      @ws
    end

    def events_store
      url = "#{@client.ws}/subscribe/events?client_id=#{@client_id}&channel=#{@channel}"
      url += "&group=#{@group}" unless @group.nil?
      url += "&events_store_type_data=#{@events_store_type_data}"
      url += "&events_store_type_value=#{@events_store_type_value}" unless @events_store_type_value.nil?
      url += "&subscribe_type=events_store"
      @ws = Faye::WebSocket::Client.new(url)
      @ws
    end

    def requests
      url = "#{@client.ws}/subscribe/requests?client_id=#{@client_id}&channel=#{@channel}"
      url += "&group=#{@group}" unless @group.nil?
      url += "&subscribe_type=commands"
      @ws = Faye::WebSocket::Client.new(url)
      @ws
    end

    def queries
      url = "#{@client.ws}/subscribe/requests?client_id=#{@client_id}&channel=#{@channel}"
      url += "&group=#{@group}" unless @group.nil?
      url += "&subscribe_type=queries"
      @ws = Faye::WebSocket::Client.new(url)
      @ws
    end
  end
end
