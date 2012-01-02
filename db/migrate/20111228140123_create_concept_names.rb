class CreateConceptNames < ActiveRecord::Migration
  def self.up
    create_table :concept_names do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :concept_names
  end
end
