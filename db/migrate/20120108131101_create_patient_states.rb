class CreatePatientStates < ActiveRecord::Migration
  def self.up
    create_table :patient_states do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :patient_states
  end
end
