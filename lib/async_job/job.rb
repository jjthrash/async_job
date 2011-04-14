module AsyncJob
  class Job < Delayed::PerformableMethod
    def self.perform_async(user, object, method, *args)
      AsyncJob::Results.create.tap do |results|
        Delayed::Job.enqueue(self.new(object, method, args, results.id))
      end
    end

    def initialize(object, method, args, results_id)
      super(object, method, args)
      @results_id = results_id
    end

    def perform
      job_results = AsyncJob::Results.find(@results_id)

      begin
        results = super
        job_results.success = true
        job_results.results = results
      rescue => error
        job_results.success = false
        job_results.results = [error.message, error.backtrace]
        Rails.logger.error "Error processing async job: #{error.message}\n#{error.backtrace.join("\n")}"
      end

      job_results.save
    end
  end
end
