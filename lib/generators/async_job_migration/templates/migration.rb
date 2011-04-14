class CreateAsyncJobResults < ActiveRecord::Migration
  def self.up
    create_table :async_job_results, :force => true do |t|
      t.boolean :success
      t.text :results
      t.timestamps
    end

    add_index :async_job_results, [:id], :name => 'async_job_results_id'
  end

  def self.down
    drop_table :async_job_results
  end
end
