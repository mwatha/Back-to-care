class CreateProgramWorkflowStates < ActiveRecord::Migration
  def self.up
    create_table :program_workflow_states do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :program_workflow_states
  end
end
