require 'active_record'

class AsyncJob::Results < ActiveRecord::Base
  serialize :results
end
