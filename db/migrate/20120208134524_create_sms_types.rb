class CreateSmsTypes < ActiveRecord::Migration
  def self.up
    create_table :sms_type do |t|                                               
      t.string :name                                                              
      t.text :description                                                       
      t.integer :creator                                                       
      t.datetime :date_created ,:default => Time.now()
      t.boolean :retired ,:default => false                                                  
      t.integer :retired_by                                                    
      t.datetime :retired_datetime                                              
      t.string :retired_reason                                                    
    end 
  end

  def self.down
    drop_table :sms_type
  end
end
