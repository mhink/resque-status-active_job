$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pry'
require 'active_job'
require 'active_support'
require 'mock_redis'
require 'resque'
require 'rspec/active_job'

MOCK_REDIS = MockRedis.new
# Resque::Status uses the same redis as Resque.
# (Even though we're faking it out by not actually using Resque.)
Resque.redis = MOCK_REDIS

ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  config.include ActiveJob::TestHelper
  config.include RSpec::ActiveJob
end
