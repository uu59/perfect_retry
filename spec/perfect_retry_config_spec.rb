require 'spec_helper'

describe PerfectRetry::Config do
  let(:logger) { Logger.new(File::NULL) }

  describe "#set_log_level" do
    let(:config) { described_class.create_from_hash(logger: logger, log_level: level) }

    subject { config.set_log_level }

    context "logger doesn't have level= method" do
      before { logger.instance_eval { undef :level= } }

      context "log_level :info" do
        let(:level) { :info }

        it "warn" do
          expect(logger).to receive(:warn).with(/Ignore log_level/)
          subject()
        end
      end

      context "log_level nil" do
        let(:level) { nil }

        it "Don't logging" do
          expect(logger).to_not receive(:warn)
          subject
        end
      end
    end

    context "nil" do
      let(:level) { nil }

      it { expect{ subject }.to_not raise_error }
      it { subject; expect(config.logger.level).to eq logger.level }
    end

    context "Fixnum" do
      let(:level) { 2 }

      it { expect{ subject }.to_not raise_error }
      it { subject; expect(config.logger.level).to eq level }
    end

    context "Symbol" do
      context "known level" do
        let(:level) { :warn }

        it { expect{ subject }.to_not raise_error }
        it { subject; expect(config.logger.level).to eq Logger::SEV_LABEL.index(level.to_s.upcase) }
      end

      context "unknown level" do
        let(:level) { :foo }

        it { expect{ subject }.to raise_error(StandardError, /Unknown.*#{level}/) }
      end
    end

    context "String" do
      context "known level" do
        let(:level) { "warn" }

        it { expect{ subject }.to_not raise_error }
        it { subject; expect(config.logger.level).to eq Logger::SEV_LABEL.index(level.to_s.upcase) }
      end

      context "unknown level" do
        let(:level) { "bar" }

        it { expect{ subject }.to raise_error(StandardError, /Unknown.*#{level}/) }
      end
    end
  end
end
