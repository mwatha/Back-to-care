class PatientTraceOutcome < ActiveRecord::Migration
  def self.up
    create_table :patient_trace_outcome do |t|                                               
      t.integer :patient_id                                                              
      t.integer :trace_outcome_id                                                       
      t.date :outcome_date 
      t.integer :creator                                                       
      t.datetime :date_created ,:default => Time.now()
      t.boolean :retired ,:default => false                                                  
      t.integer :retired_by                                                    
      t.datetime :retired_datetime                                              
      t.string :retired_reason                                                    
    end
  end

  def self.down
    drop_table :patient_trace_outcome
  end
end
