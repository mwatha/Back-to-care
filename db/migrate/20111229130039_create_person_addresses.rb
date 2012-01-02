class CreatePersonAddresses < ActiveRecord::Migration
  def self.up
    create_table :person_addresses do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :person_addresses
  end
end
