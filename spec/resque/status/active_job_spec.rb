require 'spec_helper'
require 'resque/status/active_job'

class DummyJob < ActiveJob::Base
  include Resque::Status::ActiveJob::Adapter

  def perform
    puts "HELLO! HELLO! HELLO!"
  end
end

class CompletedJob < ActiveJob::Base
  include Resque::Status::ActiveJob::Adapter

  def perform
    completed(foo: 'bar')
  end
end

class IncrementalJob < ActiveJob::Base
  include Resque::Status::ActiveJob::Adapter

  def perform(foo: 'bar')
    100.times do |i|
      at(i, 100, "HELLOOOOOO!")
    end
  end
end

RSpec.describe "A job with Resque::Status::ActiveJob::Adapter included" do
  after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  def status_hash
    Resque::Plugins::Status::Hash.get(job.job_id) 
  end

  context "when it is enqueued" do
    let(:job) { DummyJob.perform_later }
    specify { expect(performed_jobs).to be_empty }
    specify { expect(job.status).to eq(status_hash) }
    specify { expect(job.status["status"]).to eq("queued") }
  end

  context "when it is completed" do
    let(:job) { perform_enqueued_jobs { CompletedJob.perform_later } }

    specify { expect(status_hash["status"]).to eq("completed") }
  end

  context "when it is performed incrementally" do
    let(:job) { IncrementalJob.perform_later }

    it "should set its status properly 100 times", focus: true do
      original_at = job.method(:at)
      expect(job).to receive(:at) do |num, total, *messages|
        original_at.call(num, total, *messages)

        expect(status_hash["status"]).to eq("working")
        expect(status_hash["num"]).to eq(num)
        expect(status_hash["total"]).to eq(total)
        expect(status_hash["message"]).to eq(messages.first)
      end.exactly(100).times

      job.perform_now
    end
  end
end
