module RBKubeMQ
  class Utility
    def self.dump(hash)
      hash.compact!
      hash["Body"] = Base64.encode64(hash["Body"].to_s)
      Oj.dump(hash, mode: :json)
    end

    def self.load(hash)
      hash = Oj.load(hash) if hash.is_a?(String)
      unless hash["Body"].nil?
        hash["Body"] = Base64.decode64(hash["Body"].to_s)
      end
      if hash["data"].is_a?(Hash) && !hash["data"]["Body"].nil?
        hash["data"]["Body"] = Base64.decode64(hash["data"]["Body"].to_s)
      end
      hash
    end
  end
end
