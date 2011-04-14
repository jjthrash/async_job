module AsyncJob
  module ControllerMethods
    module Client
      def render_job_queued(results, options = {})
        response['Location'] = make_results_url(results)
        response['Retry-Interval'] = options[:retry_interval].to_s || '1.0'
        head 202
      end
    end

    def show
      results = AsyncJob::Results.find(params[:id])

      if results.results
        logger.debug "Returning async job results: #{results.inspect}"
        if results.success?
          if stale?(:etag => results.results)
            render :json => results.results, :status => :ok
          end
        else
          render :json => results.results, :status => :unprocessable_entity
        end
        results.destroy
      else
        render_job_queued(results)
      end
    end

    include Client
  end
end
