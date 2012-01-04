module PatientService
	#include CoreService
	#require 'bean'

  def self.demographics(person_obj)
=begin
    if person_obj.birthdate_estimated==1
      birth_day = "Unknown"
      if person_obj.birthdate.month == 7 and person_obj.birthdate.day == 1
        birth_month = "Unknown"
      else
        birth_month = person_obj.birthdate.month
      end
    else
      birth_month = person_obj.birthdate.month 
      birth_day = person_obj.birthdate.day
    end
=end
    person_names = self.names(person_obj)

    demographics = {
      :person_date_created => person_obj.date_created ,
      :gender => person_obj.gender ,
      :dob => person_obj.birthdate ,
      :first_name => person_names[:given_name] ,
      :middle_name => person_names[:middle_name] ,
      :last_name => person_names[:family_name] ,
      :cell_phone_number => self.phone_numbers(person_obj,"Cell phone number") ,
      :office_phone_number => self.phone_numbers(person_obj,"Office phone number") ,
      :home_phone_number => self.phone_numbers(person_obj,"Home phone number") ,
      :national_id => self.get_identifier(person_obj , "National id") ,
      :last_visit_date => self.last_visit_date(person_obj.id)
    }

    return demographics
  end
  
  def self.phone_numbers(person_obj,phone_number_type)
    self.get_attribute(person_obj , phone_number_type)
  end

  def self.get_attribute(person_obj , attribute_type)
    attribute_type_id = PersonAttributeType.find_by_name(attribute_type).id
    PersonAttribute.find(:first,:order =>"date_created DESC",
    :conditions => ["person_id = ? AND voided = 0 AND person_attribute_type_id = ?",
    person_obj.id,attribute_type_id]).value rescue nil
  end
  
  def self.names(person_obj)
    names = PersonName.find(:first,:order =>"date_created DESC",
      :conditions => ["person_id = ? AND voided = 0",person_obj.id])
    return {} if names.blank?
    return {:given_name => names.given_name ,
            :middle_name => names.middle_name ,
            :family_name => names.family_name 
           }
  end

  def self.get_identifier(person_obj , identifier_type)
    identifier_type = PatientIdentifierType.find_by_name(identifier_type).id
    PatientIdentifier.find(:first,:order =>"date_created DESC",
    :conditions => ["patient_id = ? AND voided = 0 AND identifier_type = ?",
    person_obj.id,identifier_type]).identifier rescue nil
  end

  def self.find_patients_by_name_and_gender(name , gender)
    given_name = name.split(" ")[0]
    last_name = name.split(" ")[1]
    return [] if given_name.blank? and last_name.blank?
    Person.find(:all,:joins =>"INNER JOIN person_name USING(person_id)",
    :conditions =>["given_name LIKE ? AND family_name LIKE ? AND gender = ?",
    "#{given_name}%","#{last_name}%",gender],:limit => 100)
  end

  def self.last_visit_date(patient_id)
    encounter_types = ["VITALS","HIV RECEPTION",
                     "HIV STAGING","DISPENSING",
                     "ART VISIT","TREATMENT"
                    ]
    encounter_type_ids = EncounterType.find_all_by_name(encounter_types).collect{|e|e.id}
    Encounter.find(:first, :order => "encounter_datetime DESC",
      :conditions =>["patient_id = ? AND voided = 0 AND encounter_type IN(?)",
      patient_id , encounter_type_ids]).encounter_datetime.to_date rescue nil
  end

end
