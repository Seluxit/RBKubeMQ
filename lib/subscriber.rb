module RBKubeMQ
  class Subscriber < Faye::WebSocket::Client
    include Check

    def initialize(client:, client_id: nil, channel: nil, group: nil,
      events_store_type_data: 1, events_store_type_value: nil, type: "events")
      is_class?(client, [RBKubeMQ::Client], "client")
      type = type.to_s
      is_in_list?(type, ["events", "events_store", "commands", "queries"], "type")
      @client = client
      @client_id  = client_id
      @channel = channel
      @group = group
      @events_store_type_data = events_store_type_data
      @events_store_type_value = events_store_type_value
      @type = type
      url = "#{@client.ws}/subscribe/"
      case type
      when "events", "events_store"
        url += "events"
      when "commands", "queries"
        url += "requests"
      end
      url += "?client_id=#{@client_id}&channel=#{@channel}"
      url += "&group=#{@group}" unless @group.nil?
      url += "&subscribe_type=#{@type}"
      super(url)
    end

    attr_reader :client_id, :channel, :meta, :store, :group,
      :events_store_type_data, :events_store_type_value, :type
  end
end
