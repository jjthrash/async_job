module AsyncJob::ControllerMethods
  def get
    results = AsyncJob::Results.find(params[:id])

    if results.user && results.user != current_user
      logger.error "User fetching the results (#{current_user.inspect}) is not the same as the user who requested the job (#{results.user.inspect})"
      render :json => ["Not authorized to get results"], :status => :unprocessable_entity
      return
    end

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

  def render_job_queued(results, options = {})
    response['Retry-Location'] = make_results_url(results)
    response['Retry-Interval'] = options[:retry_interval].to_s || '1.0'
    head 202
  end
end
