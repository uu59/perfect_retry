require "logger"

class PerfectRetry
  class Config < Struct.new(:limit, :rescues, :logger, :sleep, :ensure)
    def sleep_sec(count)
      if sleep.is_a?(Proc)
        sleep.call(count)
      else
        sleep
      end
    end
  end
end
