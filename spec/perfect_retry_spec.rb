require 'spec_helper'

describe PerfectRetry do
  describe "register config" do
    after { PerfectRetry.deregister_all }

    it "register and deregister" do
      PerfectRetry.register(:foo) do |conf|
        conf.limit = 3
      end

      aggregate_failures do
        expect(PerfectRetry.registered_config_all.to_a.length).to eq 1
        expect(PerfectRetry.registered_config(:foo).limit).to eq 3

        PerfectRetry.deregister_all

        expect(PerfectRetry.registered_config_all.to_a.length).to eq 0
        expect(PerfectRetry.registered_config(:foo)).to eq nil
      end
    end
  end

  describe "#initialize" do
    it "use default without arguments" do
      pr = PerfectRetry.new
      aggregate_failures do
        PerfectRetry::DEFAULTS.each do |k,v|
          expect(pr.config.send(k)).to eq v
        end
      end
    end

    it "configure with block" do
      pr = PerfectRetry.new do |config|
        config.limit = 99
      end
      expect(pr.config.limit).to eq 99
    end
  end

  describe "#with_retry" do
    it 'return block value' do
      ret = PerfectRetry.with_retry do
        42
      end
      expect(ret).to eq 42
    end

    describe "raise and retry" do
      let(:retry_limit) { 4 }

      before do
        PerfectRetry.register(:all_exception) do |conf|
          conf.sleep = lambda{|n| n }
          conf.limit = retry_limit
          conf.rescues = [Exception]
          conf.logger = Logger.new(File::NULL)
        end
      end
      after { PerfectRetry.deregister_all }

      describe "sleep time" do
        let(:pr) { PerfectRetry.new(:all_exception) }

        it do
          retry_limit.times do |n|
            expect(pr).to receive(:sleep_before_retry).with(n + 1)
          end

          expect {
            pr.with_retry do
              raise "foo"
            end
          }.to raise_error(PerfectRetry::TooManyRetry)
        end
      end
    end

    describe "ensure" do
      let(:ensure_double) { double("ensure") }
      let(:pr) { PerfectRetry.new(:test_ensure) }

      before do
        PerfectRetry.register(:test_ensure) do |config|
          config.ensure = proc{ ensure_double.call() }
          config.logger = Logger.new(File::NULL)
          config.sleep = proc{|n| 0 }
        end
      end

      it "without error" do
        expect(ensure_double).to receive(:call).once

        pr.with_retry { 1 }
      end

      it "with error and reached retry limit" do
        expect(ensure_double).to receive(:call).once

        expect { pr.with_retry { raise "foo" } }.to raise_error(PerfectRetry::TooManyRetry)
      end

      it "with uncaught error" do
        expect(ensure_double).to receive(:call).once

        expect { pr.with_retry { raise Exception, "foo" } }.to raise_error(Exception)
      end
    end

    describe "retry manually" do
      before do
        PerfectRetry.register(:no_retry) do |conf|
          conf.limit = 0
        end
      end

      it "couldn't affect config.limit" do
        count = 5

        d1 = double("dummy1")
        d2 = double("dummy2")
        expect(d1).to receive(:call).exactly(count)
        expect(d2).to receive(:call).exactly(1)

        expect {
          PerfectRetry.with_retry(:no_retry) do
            d1.call()
            throw :retry if (count -= 1) > 0
            d2.call()
            raise "foo"
          end
        }.to raise_error(PerfectRetry::TooManyRetry)
      end
    end

    describe "logger" do
      let(:pr) { PerfectRetry.new }
      let(:error_message) { "ERROR!!"}
      let(:error_type) { StandardError }

      before do
        pr.config.sleep = lambda{|n| 0}
      end

      subject {
        pr.with_retry do
          raise error_type.new(error_message)
        end
      }

      context "logging retry limit" do
        before { pr.config.limit = limit }

        context "natural number" do
          let(:limit) { 5 }

          it do
            expect(pr.config.logger).to receive(:warn).with(%r!\[[0-9]+/#{pr.config.limit}\]!).exactly(pr.config.limit).times

            expect { subject }.to raise_error(PerfectRetry::TooManyRetry)
          end
        end

        context "infinity" do
          let(:limit) { nil }

          it do
            expect(pr.config.logger).to receive(:warn).with(%r!\[[0-9]+/Infinitiy\]!).at_least(1)

            expect {
              pr.with_retry do |times|
                raise "foo" if times < 10
                raise Exception, "stop"
              end
            }.to raise_error(Exception)
          end
        end
      end

      describe "log message content" do
        after { expect { subject }.to raise_error(PerfectRetry::TooManyRetry) }

        it "exception message" do
          expect(pr.config.logger).to receive(:warn).with(/#{error_message}/).exactly(pr.config.limit).times
        end

        it "exception type(class)" do
          expect(pr.config.logger).to receive(:warn).with(/#{error_type}/).exactly(pr.config.limit).times
        end

        it "'Retrying'" do
          expect(pr.config.logger).to receive(:warn).with(/Retrying/).exactly(pr.config.limit).times
        end

        it "Retry count number" do
          pr.config.limit.times do |n|
            expect(pr.config.logger).to receive(:warn).with(/\[#{n + 1}\/#{pr.config.limit}\]/)
          end
        end
      end
    end
  end
end
