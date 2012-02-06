class Sms < ActiveRecord::Migration
  def self.up
    create_table :sms do |t|                                                    
      t.integer :sms_type_id                                                    
      t.integer :person_id                                                      
      t.integer :provider_id                                                    
      t.text :message                                                           
      t.integer :number                                                         
      t.datetime :date_created                                                  
      t.boolean :voided                                                         
      t.integer :voided_by                                                      
      t.datetime :date_voided                                                   
    end
  end

  def self.down
    drop_table :sms
  end
end
