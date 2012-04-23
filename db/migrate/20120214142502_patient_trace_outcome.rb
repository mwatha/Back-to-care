class PatientTraceOutcome < ActiveRecord::Migration
  def self.up
    create_table :patient_trace_outcome do |t|                                               
      t.interger :patient_id                                                              
      t.interger :trace_outcome_id                                                       
      t.date :outcome_date 
      t.interger :creator                                                       
      t.datetime :date_created ,:default => Time.now()
      t.boolean :retired ,:default => false                                                  
      t.interger :retired_by                                                    
      t.datetime :retired_datetime                                              
      t.string :retired_reason                                                    
    end
  end

  def self.down
    drop_table :patient_trace_outcome
  end
end
