RBKubeMQ [![Gem Version](https://badge.fury.io/rb/rbkubemq.svg)](https://badge.fury.io/rb/rbkubemq)
==============================

This is a quick gem created to manage [KubeMQ](https://kubemq.io/) with Ruby.

To install ArangoRB: `gem install RBKubeMQ`  
To use it in your application: `require rbkubemq`  
For examples, look the tests in "/spec/lib/spec_helper".  
It requires the gems "HTTParty", "Oj" and "faye-websocket".

## Used classes

* [RBKubeMQ::Client](#RKMQCLient): to manage a general client
* [RBKubeMQ::Sender](#RKMQSender): to manage a sender
* [RBKubeMQ::Streamer](#RKMQStreamer): to create a websocket to send data
* [RBKubeMQ::Subscriber](#RKMQsubscriber): to create a websocket to receive data
* [RBKubeMQ::Utility](#RKMQutility): to parse and load easier the data
* [RBKubeMQ::Error](#RKMQerror): to manage generic error

<a name="RKMQCLient"></a>
## RBKubeMQ::Client

Arango::Server is used to manage a connection with KubeMQ.

``` ruby
client = RBKubeMQ::Client.new host: "YOUR_HOST", port: "8080", tls: false # tls is true then it will make your requests with https and wss instead of http or ws
```

<a name="RKMQSender"></a>
## RBKubeMQ::Sender

Sender it is used to do HTTP requests to KubeMQ. It manage event, request, query and response requests.

``` ruby
sender = client.sender client_id: "YOUR_CLIENT", channel: "YOUR_CHANNEL",
meta: nil, store: false, timeout: 1000, cache_key: nil, cache_ttl: nil
```

The possible request that you can do are the following:

``` ruby
sender.event("YOUR MESSAGE") # send an event
sender.request("YOUR MESSAGE") # send a request (we do not expect a body)
sender.query("YOUR MESSAGE") # send a query  (we expect a body)
sender.response(received_request, message: "YOUR MESSAGE") # send a response to a request (the received request is the one received with a subscriber)
```

You can overwrite the default values by inserting them as attributes, like this:

``` ruby
sender.event("YOUR MESSAGE", client_id: "client_id")
```

Note that client_id, channel are mandatory values that need to be insert either at the initialization or during the request.

<a name="RKMQStreamer"></a>
## RBKubeMQ::Streamer

Streamer it is used to create a stream websocket that it will be used to communicate with the KubeMQ. By using an eventmachine the structure of a streamer can be similar to one of a websocket.

```ruby
i = 0
EM.run do
  streamer = client.streamer(client_id: "YOUR_CLIENT", channel: "YOUR_CHANNEL",
    meta: nil, store: false)
  ws = streamer.start # Create a websocket by starting it

  ws.on :open do |event|
    p [:open]
  end

  ws.on :message do |event|
    p [:message, RBKubeMQ::Utility.load(event.data)]
  end

  ws.on :close do |event|
    p [:close]
    ws = nil; EM.stop
  end

  # Send a message every second
  timer = EM::PeriodicTimer.new(1) do
    i += 1
    puts "SENDING #{i}"
    streamer.send(i, meta: "Stream") # Note that we use streamer and not ws to send the stream
  end
end
```

<a name="RKMQSubscriber"></a>
## RBKubeMQ::Subscriber

Subscriber is liked the streamer but it is used only to subscribe to a client_id and a channel. You can use groups to subdivide the queue between different machines.
It cannot be use to send data.

```ruby
EM.run do
  subscriber = client.subscriber(client_id: "YOUR_CLIENT", channel: "YOUR_CHANNEL",
    group: "YOUR_GROUP")
  ws = subscriber.events

  ws.on :open do |event|
    p [:open]
  end

  ws.on :message do |event|
    p [:message, RBKubeMQ::Utility.load(event.data)]
  end

  ws.on :close do |event|
    p [:close]
    ws = nil; EM.stop
  end
end
```

In the example the subscriber is for events.
You can subscribe to "events_store", "requests", and "queries".

<a name="RKMQUtility"></a>
## RBKubeMQ::Utility

```ruby
RBKubeMQ::Utility.dump(hash) # Convert hash in correct format for KubeMQ
RBKubeMQ::Utility.load(string) # Parse hash in human format from KubeMQ
```

<a name="RKMQerror"></a>
## RBKubeMQ::Error

RBKubeMQ::Error is used to manage generic errors inside of the gem.
