require 'active_job'
require 'active_support/concern'

module Resque::Status::ActiveJob
  module Adapter
    extend Forwardable
    extend ActiveSupport::Concern

    STATUS_QUEUED = 'queued'
    STATUS_WORKING = 'working'
    STATUS_COMPLETED = 'completed'
    STATUS_FAILED = 'failed'
    STATUS_KILLED = 'killed'
    STATUSES = [
      STATUS_QUEUED,
      STATUS_WORKING,
      STATUS_COMPLETED,
      STATUS_FAILED,
      STATUS_KILLED
    ].freeze

    # The error class raised when a job is killed
    class Killed < RuntimeError; end
    class NotANumber < RuntimeError; end

    included do
      before_enqueue :create_status_hash
      before_perform :mark_status_working
    end

    def create_status_hash
      Resque::Plugins::Status::Hash.create(self.job_id)
    end

    def mark_status_working
      set_status({'status' => STATUS_WORKING})
    end

    # ----------------------------------------------
    # Lifted wholesale from Resque::Plugins::Status
    # ----------------------------------------------
    def status=(new_status)
      Resque::Plugins::Status::Hash.set(self.job_id, *new_status)
    end

    # get the Resque::Plugins::Status::Hash object for the current uuid
    def status
      Resque::Plugins::Status::Hash.get(self.job_id)
    end

    def name
      "#{self.class.name}"
    end

    # Checks against the kill list if this specific job instance should be killed
    # on the next iteration
    def should_kill?
      Resque::Plugins::Status::Hash.should_kill?(self.job_id)
    end

    # set the status of the job for the current itteration. <tt>num</tt> and
    # <tt>total</tt> are passed to the status as well as any messages.
    # This will kill the job if it has been added to the kill list with
    # <tt>Resque::Plugins::Status::Hash.kill()</tt>
    def at(num, total, *messages)
      if total.to_f <= 0.0
        raise(NotANumber, "Called at() with total=#{total} which is not a number")
      end
      tick({
        'num' => num,
        'total' => total
      }, *messages)
    end

    # sets the status of the job for the current itteration. You should use
    # the <tt>at</tt> method if you have actual numbers to track the iteration count.
    # This will kill the job if it has been added to the kill list with
    # <tt>Resque::Plugins::Status::Hash.kill()</tt>
    def tick(*messages)
      kill! if should_kill?
      set_status({'status' => STATUS_WORKING}, *messages)
    end

    # set the status to 'failed' passing along any additional messages
    def failed(*messages)
      set_status({'status' => STATUS_FAILED}, *messages)
    end

    # set the status to 'completed' passing along any addional messages
    def completed(*messages)
      set_status({
        'status' => STATUS_COMPLETED,
        'message' => "Completed at #{Time.now}"
      }, *messages)
    end

    # kill the current job, setting the status to 'killed' and raising <tt>Killed</tt>
    def kill!
      set_status({
        'status' => STATUS_KILLED,
        'message' => "Killed at #{Time.now}"
      })
      raise Killed
    end

    private
    def set_status(*args)
      self.status = [status, {'name'  => self.name}, args].flatten
    end
  end
end
