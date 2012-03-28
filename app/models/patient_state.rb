class PatientState < ActiveRecord::Base
  set_table_name "patient_state"
  set_primary_key "patient_state_id"

  belongs_to :patient_program, :conditions => {:voided => 0}                    
  belongs_to :program_workflow_state, :foreign_key => :state, :class_name => 'ProgramWorkflowState'
end
