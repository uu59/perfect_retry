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

    def set_log_level
      unless logger.respond_to?(:level=)
        logger.warn("Ignore log_level setting because your logger don't have `level=` method. Info: `config.log_level = nil` will not try to change log level.")
        return
      end

      case log_level
      when Fixnum
        logger.level = log_level
        return
      when String, Symbol
        if int = Logger::SEV_LABEL.index(log_level.to_s.upcase)
          logger.level = int
          return
        end
      when nil
        # Don't touch when nil
        return
      end

      raise "Unknown log level '#{log_level}'(#{log_level.class})"
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
