class PersonName < ActiveRecord::Base
  set_table_name :person_name
  set_primary_key :person_name_id
  belongs_to :person, :foreign_key => :person_id, :conditions => {:voided => 0}
end
