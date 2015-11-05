require "perfect_retry/version"
require "perfect_retry/config"

class PerfectRetry
  class TooManyRetry < StandardError; end

  REGISTERED_CONFIG = { }

  DEFAULTS = {
    limit: 5,
    rescues: [StandardError],
    logger: Logger.new(STDERR),
    sleep: lambda{|n| n ** 2},
    ensure: lambda{},
  }.freeze

  def self.with_retry(config_key = nil, &block)
    new(config_key).with_retry(&block)
  end

  def self.register(name, &block)
    config = Config.create_from_hash(DEFAULTS)
    block.call(config)
    REGISTERED_CONFIG[name] = config
  end

  def self.registered_config_all
    REGISTERED_CONFIG
  end

  def self.registered_config(key)
    REGISTERED_CONFIG[key]
  end

  def self.deregister_all
    REGISTERED_CONFIG.clear
  end

  attr_reader :config

  def initialize(config_key = nil)
    @config = REGISTERED_CONFIG[config_key] || default_config
  end

  def default_config
    Config.create_from_hash(DEFAULTS)
  end

  def with_retry(&block)
    count = 0
    begin
      retry_with_catch(count, &block)
    rescue *config.rescues => e
      if should_retry?(count)
        count += 1
        config.logger.warn "[#{count}/#{config.limit || "Infinitiy"}] Retrying after #{config.sleep_sec(count)} seconds. Ocurred: #{e}(#{e.class})"
        sleep_before_retry(count)
        retry
      end

      raise TooManyRetry.new("too many retry (#{config.limit} times)")
    ensure
      config.ensure.call
    end
  end

  def sleep_before_retry(count)
    sleep config.sleep_sec(count)
  end

  def should_retry?(count)
    return true unless config.limit
    count < config.limit
  end

  private

  def retry_with_catch(count, &block)
    proc do
      catch(:retry) do
        return block.call(count)
      end

      redo # reached here only `throw :retry` called in a block
    end.call
  end
end
