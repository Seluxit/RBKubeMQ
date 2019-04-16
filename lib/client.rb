module RBKubeMQ
  class Client
    include Check

    def initialize(host:, port: "9090", tls: false)
      @host = host
      @port = port
      is_class?(tls, [FalseClass, TrueClass], "tls")
      @tls  = tls
      @uri = "http"
      @uri += "s" if @tls
      @uri += "://#{host}:#{port}"
      @ws = "ws"
      @ws += "s" if @tls
      @ws += "://#{host}:#{port}"
    end

    attr_reader :host, :port, :uri, :tls, :ws

    def sender(*args)
      args[0] ||= {}
      args[0][:client] = self if args[0].is_a?(Hash)
      RBKubeMQ::Sender.new(*args)
    end

    def streamer(*args)
      args[0] ||= {}
      args[0][:client] = self if args[0].is_a?(Hash)
      RBKubeMQ::Streamer.new(*args)
    end

    def subscriber(*args)
      args[0] ||= {}
      args[0][:client] = self if args[0].is_a?(Hash)
      RBKubeMQ::Subscriber.new(*args)
    end
  end
end
