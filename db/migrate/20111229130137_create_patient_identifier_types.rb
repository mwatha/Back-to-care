class CreatePatientIdentifierTypes < ActiveRecord::Migration
  def self.up
    create_table :patient_identifier_types do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :patient_identifier_types
  end
end
