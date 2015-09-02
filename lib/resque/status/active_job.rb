require 'resque-status'
require 'active_support'

module Resque::Status
  module ActiveJob
    extend ActiveSupport::Autoload

    autoload :Adapter
  end
end
