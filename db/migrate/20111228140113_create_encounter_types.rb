class CreateEncounterTypes < ActiveRecord::Migration
  def self.up
    create_table :encounter_types do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :encounter_types
  end
end
