require 'active_record'

module AsyncJob
  class Results < ActiveRecord::Base
    set_table_name "async_job_results"

    serialize :results
  end
end
