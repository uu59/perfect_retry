require 'spec_helper'

describe PerfectRetry do
  describe "#with_retry" do
    it 'return block value' do
      ret = PerfectRetry.with_retry do
        42
      end
      expect(ret).to eq 42
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

      it "logging 'Retrying'" do
        expect(pr.config.logger).to receive(:warn).with(/Retrying/).exactly(pr.config.limit).times

        expect { subject }.to raise_error(PerfectRetry::TooManyRetry)
      end

      context "logging retry count" do
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

      it "logging error message" do
        expect(pr.config.logger).to receive(:warn).with(/#{error_message}/).exactly(pr.config.limit).times

        expect { subject }.to raise_error(PerfectRetry::TooManyRetry)
      end

      it "logging error type" do
        expect(pr.config.logger).to receive(:warn).with(/#{error_type}/).exactly(pr.config.limit).times

        expect { subject }.to raise_error(PerfectRetry::TooManyRetry)
      end
    end
  end
end
