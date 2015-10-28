require "perfect_retry/version"
require "perfect_retry/config"

class PerfectRetry
  class TooManyRetry < StandardError; end

  REGISTERED_CONFIG = {
  }

  DEFAULTS = {
    limit: 5,
    rescues: [StandardError],
    logger: Logger.new(STDERR),
    sleep: lambda{|n| n ** 2},
    ensure: lambda{},
  }.freeze

  def self.with_retry(&block)
    new.with_retry(&block)
  end

  def self.register(name, &block)
    REGISTERED_CONFIG[name] = block.call(Config.new)
  end

  def self.deregister_all
    REGISTERED_CONFIG.clear
  end

  attr_reader :config

  def initialize
    @config = Config.new
    DEFAULTS.each do |k, v|
      @config.send("#{k}=", v)
    end
  end

  def with_retry(&block)
    count = 0
    catch(:retry) do
      begin
        block.call(count)
      rescue *config.rescues => e
        config.logger.warn "[#{count + 1}/#{config.limit || "Infinitiy"}] Retrying after #{config.sleep_sec(count)} seconds. Ocurred: #{e}(#{e.class})"

        count += 1
        if retry?(count)
          sleep_before_retry(count)
          retry
        end

        raise TooManyRetry.new("too many retry (#{config.limit} times)")
      ensure
        config.ensure.call
      end
    end
  end

  def sleep_before_retry(count)
    sleep config.sleep_sec(count)
  end

  def retry?(count)
    return true unless config.limit
    count < config.limit
  end
end
