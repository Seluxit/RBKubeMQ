module RBKubeMQ
  class Utility
    def self.dump(hash)
      hash.compact!
      hash["Body"] = Base64.encode64(Oj.dump(hash["Body"], mode: :json))
      Oj.dump(hash, mode: :json)
    end

    def self.load(hash, parse_body: true)
      hash = Oj.load(hash, mode: :json, symbol_keys: false) if hash.is_a?(String)
      unless hash["Body"].nil?
        hash["Body"] = parsing_body(hash["Body"], parse_body: parse_body)
      end
      if hash["data"].is_a?(Hash) && !hash["data"]["Body"].nil?
        hash["data"]["Body"] = parsing_body(hash["data"]["Body"],
          parse_body: parse_body)
      end
      hash
    end

    private

    def self.parsing_body(body, parse_body: true)
      decoded = Base64.decode64(body.to_s)
      return decoded unless parse_body
      begin
        return Oj.load(decoded, mode: :json, symbol_keys: false)
      rescue
        return decoded
      end
    end
  end
end
