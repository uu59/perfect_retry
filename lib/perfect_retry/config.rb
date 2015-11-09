require "logger"

class PerfectRetry
  class Config < Struct.new(:limit, :rescues, :dont_rescues, :logger, :sleep, :ensure, :log_level)
    def self.create_from_hash(hash)
      config = new
      hash.each do |k, v|
        config.send("#{k}=", v)
      end
      config
    end

    def sleep_sec(count)
      if sleep.is_a?(Proc)
        sleep.call(count)
      else
        sleep
      end
    end
  end
end
