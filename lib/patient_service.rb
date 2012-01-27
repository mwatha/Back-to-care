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
      :person_id => person_obj.id ,
      :person_date_created => person_obj.date_created ,
      :gender => person_obj.gender ,
      :dob => person_obj.birthdate ,
      :first_name => person_names[:given_name] ,
      :middle_name => person_names[:middle_name] ,
      :last_name => person_names[:family_name] ,
      :cell_phone_number => self.phone_numbers(person_obj,"Cell phone number") ,
      :office_phone_number => self.phone_numbers(person_obj,"Office phone number") ,
      :home_phone_number => self.phone_numbers(person_obj,"Home phone number") ,
      :occupation => self.get_attribute(person_obj,"Occupation") ,
      :home_district => self.current_address(person_obj,"home_district") ,
      :curent_place_of_residence => self.get_attribute(person_obj,"Current Place Of Residence") ,
      :current_address => self.current_address(person_obj) ,
      :land_mark => self.current_address(person_obj,"land_mark") ,
      :national_id => self.get_identifier(person_obj , "National id") ,
      :arv_number => self.get_identifier(person_obj , "ARV Number") ,
      :last_visit_date => self.last_visit_date(person_obj) ,
      :last_regimen_given => self.last_regimen_given(person_obj) ,
      :latest_state => self.latest_state(person_obj)
    }

    return demographics
  end
  
  def self.latest_state(person_obj)
     program_id = Program.find_by_name('HIV PROGRAM').id
     last_visit_date = self.last_visit_date(person_obj) || Date.today
     patient_state = PatientState.find(:first,                                  
                      :joins => "INNER JOIN patient_program p 
                      ON p.patient_program_id = patient_state.patient_program_id",
                      :conditions =>["patient_state.voided = 0 AND p.voided = 0 
                      AND p.program_id = ? AND start_date <= ? AND p.patient_id =?",
                      program_id,last_visit_date.to_date,person_obj.id],
                      :order => "patient_state_id DESC")

     return if patient_state.blank?
     ConceptName.find_by_concept_id(patient_state.program_workflow_state.concept_id).name
  end
 
  def self.last_regimen_given(person_obj)
    concept_name = ConceptName.find_by_name("WHAT TYPE OF ANTIRETROVIRAL REGIMEN")
    obs = Observation.find(:first,:order =>"obs_datetime DESC , date_created DESC",
    :conditions => ["person_id = ? AND voided = 0 AND concept_id = ?",
    person_obj.id,concept_name.concept_id]) 
    return if obs.blank?
    ConceptName.find_by_concept_id(obs.value_coded).name
  end
  
  def self.current_address(person_obj,address = "city_village")
    person_address = PersonAddress.find(:first,:order =>"date_created DESC",
    :conditions => ["person_id = ? AND voided = 0",
    person_obj.id])
    
    case address
      when "county_district"
        return person_address.county_district 
      when "city_village"
        return person_address.city_village 
      when "land_mark"
        return person_address.address1 
      when "home_district"
        return person_address.address2
    end
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

  def self.last_visit_date(patient)
    encounter_types = ["VITALS","HIV RECEPTION",
                     "HIV STAGING","DISPENSING",
                     "ART VISIT","TREATMENT"
                    ]
    encounter_type_ids = EncounterType.find_all_by_name(encounter_types).collect{|e|e.id}
    Encounter.find(:first, :order => "encounter_datetime DESC",
      :conditions =>["patient_id = ? AND voided = 0 AND encounter_type IN(?)",
      patient.id , encounter_type_ids]).encounter_datetime.to_date rescue nil
  end

  def self.outcomes(outcome_name , start_date, end_date)                             
    program_id = Program.find_by_name('HIV PROGRAM').id
    patient_ids = []                                                  
    PatientState.find_by_sql("SELECT * FROM (                                   
        SELECT s.patient_program_id, patient_id,patient_state_id,start_date,    
               n.name name,state,p.date_enrolled date_enrolled                  
        FROM patient_state s                                                    
        INNER JOIN patient_program p ON p.patient_program_id =                  
                                        s.patient_program_id                    
        INNER JOIN program_workflow pw ON pw.program_id = p.program_id          
        INNER JOIN program_workflow_state w ON w.program_workflow_id =          
                                               pw.program_workflow_id           
                   AND w.program_workflow_state_id = s.state                    
        INNER JOIN concept_name n ON w.concept_id = n.concept_id                
        WHERE p.voided = 0 AND s.voided = 0                                     
        AND (patient_start_date(patient_id) >= '#{start_date}'   
        AND patient_start_date(patient_id) <= '#{end_date}')                   
        AND p.program_id = #{program_id}                                      
        ORDER BY patient_state_id DESC,                                         
        start_date DESC                                                         
      ) K                                                                       
      GROUP BY K.patient_program_id HAVING (name = '#{outcome_name}')           
      ORDER BY K.patient_state_id , K.start_date").map do |state|               
        patient_ids << state.patient_id 
      end                                                                       
    patient_ids.uniq                                        
  end


  def self.report(report_type , start_date , end_date)
    patients = []
    case report_type
      when 'Died'
        self.died(start_date,end_date).map do |patient_id|
          patients << self.demographics(Person.find(patient_id))
        end
      when 'Defaulters'
        self.art_defaulted_patients(start_date,end_date).map do |patient_id|
          patients << self.demographics(Person.find(patient_id))
        end
      when 'Missed appointments'
        self.missed_appointment(start_date,end_date).map do |patient_id|
          patients << self.demographics(Person.find(patient_id))
        end
      when 'Transfer out'
        self.transferred_out_patients(start_date,end_date).map do |patient_id|
          patients << self.demographics(Person.find(patient_id))
        end
      when 'ART stopped'
        self.art_stopped_patients(start_date,end_date).map do |patient_id|
          patients << self.demographics(Person.find(patient_id))
        end
      when 'On ART'
        self.on_antiretroviral_therapy(start_date,end_date).map do |patient_id|
          patients << self.demographics(Person.find(patient_id))
        end
    end
    return patients
  end


  protected

  def self.art_defaulted_patients(start_date,end_date)                                 
    self.outcomes('PATIENT DEFAULTED',start_date , end_date)                        
  end                                                                           
                                                                                
  def self.art_stopped_patients(start_date,end_date)                             
    self.outcomes('TREATMENT STOPPED',start_date ,end_date)                     
  end                                                                           
                                                                                
  def self.transferred_out_patients(start_date,end_date)                                           
    self.outcomes('PATIENT TRANSFERRED OUT',start_date,end_date)               
  end                                                                           
                                                                                
  def self.died(start_date,end_date)                                        
    self.outcomes("PATIENT DIED",start_date,end_date)          
  end
                                                                                
  def self.on_antiretroviral_therapy(start_date,end_date)                                        
    self.outcomes("On antiretroviral therapy",start_date,end_date)          
  end
                                                                                
  def self.missed_appointment(start_date,end_date)                                        
    hiv_reception_id = EncounterType.find_by_name("HIV RECEPTION").id
    appointment_concept_id = ConceptName.find_by_name("APPOINTMENT DATE").concept_id

    Observation.find_by_sql("SELECT o.person_id FROM obs o 
    WHERE o.obs_datetime >= '#{start_date.strftime('%Y-%m-%d 00:00:00')}' 
    AND o.obs_datetime <= '#{end_date.strftime('%Y-%m-%d 23:59:59')}' 
    AND o.concept_id=#{appointment_concept_id} AND o.person_id 
    NOT IN(SELECT e.patient_id FROM encounter e INNER JOIN obs i 
    ON e.encounter_id=i.encounter_id WHERE encounter_type = #{hiv_reception_id} 
    AND encounter_datetime >= o.value_datetime AND encounter_datetime <= o.value_datetime
    ) GROUP BY o.person_id ORDER BY o.obs_datetime DESC").collect{|obs|obs.person_id}

  end
end
