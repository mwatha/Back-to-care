class CreateProgramWorkflows < ActiveRecord::Migration
  def self.up
    create_table :program_workflows do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :program_workflows
  end
end
