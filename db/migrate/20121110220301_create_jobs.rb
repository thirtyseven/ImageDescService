class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.timestamps
      t.string :state, :null => false, :default => 'new'
      t.string :job_type
      t.integer :user_id
      t.text :enter_params
      t.text :exit_params
      t.string :error_explanation
    end
    
    add_constraint 'jobs', 'jobs_user_id', 'user_id', 'users', 'id'
  end

  def self.down
    drop_table :jobs
  end
end
