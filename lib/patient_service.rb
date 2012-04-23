module PatientService
	#include CoreService
	#require 'bean'

  def self.demographics(person_obj)
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
      :latest_appointment_date_given => self.get_last_appointment_date_given(person_obj) ,
      :last_visit_date => self.last_visit_date(person_obj) ,
      :last_regimen_given => self.last_regimen_given(person_obj) ,
      :last_drugs_given => self.last_drugs_given(person_obj) ,
      :latest_state => self.latest_state(person_obj) ,
      :traced_outcome => self.traced_outcome(person_obj)
    }

    return demographics
  end

  def self.traced_outcome(person)
    outcome = TraceOutcomeType.find(:first,
      :joins =>"INNER JOIN patient_trace_outcome p 
      ON trace_outcome_type.id = p.trace_outcome_id
      AND p.id = (SELECT id FROM patient_trace_outcome WHERE patient_id = p.patient_id
      AND p.outcome_date = outcome_date ORDER BY date_created DESC LIMIT 1)",
      :conditions =>["patient_id = ?", person.id])
  end
  
  def self.get_last_appointment_date_given(person)
    concept_id = ConceptName.find_by_name("Appointment date").concept_id
    Observation.find(:first,:order =>"obs_datetime DESC,date_created DESC",
      :conditions =>["voided=0 AND person_id=? AND concept_id = ?",person.id,
      concept_id]).value_datetime.to_date rescue nil
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

  def self.last_drugs_given(person_obj)
    concept_name = ConceptName.find_by_name("Amount dispensed")
    obs_datetime = Observation.find(:first,:order =>"obs_datetime DESC , date_created DESC",
    :conditions => ["person_id = ? AND voided = 0 AND concept_id = ?",
    person_obj.id,concept_name.concept_id]).obs_datetime rescue nil 
    return if obs_datetime.blank?

    start_date = obs_datetime.strftime("%Y-%m-%d 00:00:00")
    end_date = obs_datetime.strftime("%Y-%m-%d 23:59:59")

    obs = Observation.find(:all,
    :conditions => ["person_id = ? AND voided = 0 AND concept_id = ? AND
    obs_datetime >=? AND obs_datetime <=?",person_obj.id,concept_name.concept_id,
    start_date,end_date])

    drug_orders = DrugOrder.find(:all,:conditions =>["order_id IN(?)",obs.collect{|ob|ob.order_id}])
    drugs_given = {}

    drug_orders.collect do |drug_order|
      name = drug_order.drug.name
      if drugs_given[name].blank?
        drugs_given[name] = {:dose => drug_order.equivalent_daily_dose,
         :quantity => drug_order.quantity,
         :dispensed_date => drug_order.order.start_date}
      else
        drugs_given[name] = {:dose => drug_order.equivalent_daily_dose,
          :quantity => (drugs_given[name][:quantity] + drug_order.quantity),
          :dispensed_date => drug_order.order.start_date}
      end
    end
    drugs_given
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
    identifier_type = PatientIdentifierType.find_by_name("National ID").id
    records = Person.find(:all,:limit => 100,
    :select =>"person.person_id patient_id ,given_name,family_name,gender,birthdate,
    DATE(encounter_datetime) visit_date,identifier national_id",
    :joins =>"INNER JOIN person_name n ON person.person_id = n.person_id
    INNER JOIN patient_identifier i ON i.patient_id = person.person_id AND
    identifier_type = #{identifier_type}
    LEFT JOIN encounter e ON e.patient_id = person.person_id 
    AND encounter_type IN (54,53,68,25,6,51,7,9)",
    :conditions =>["given_name LIKE ? AND family_name LIKE ? AND gender = ?",
    "#{given_name}%","#{last_name}%",gender],
    :group => "person.person_id",:order =>"encounter_datetime DESC")
     
    demographics = {} 

    (records || []).collect do |r|
      demographics[r.patient_id] = {:patient_id => r.patient_id,
        :first_name => r.given_name ,:last_name => r.family_name , 
        :gender => r.gender,:dob => r.birthdate , 
        :last_visit_date => r.visit_date , :national_id => r.national_id}
    end
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
      when 'SMS status'
        self.sms_status(start_date,end_date).map do |record|
          patients << {:person_id => record[0] ,:gender => record[3] ,                                            
                       :dob => record[4] , :first_name => record[1] ,                                
                       :last_name => record[2],:national_id => record[7],
                       :send_date => record[5],
                       :message => record[9],:sender => record[8],
                       :number => record[10],:status => record[11] }
        end
      when 'Missed appointments'
        self.missed_appointment(start_date,end_date).map do |record|
          patients << {:person_id => record[0] ,:gender => record[3] ,                                            
                       :dob => record[4] , :first_name => record[1] ,                                
                       :last_name => record[2],:national_id => record[7],
                       :last_visit_date => record[5] }
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
      when 'Outcome status'
        self.traced_outcome_status(start_date,end_date).map do |record|
          patients << {:person_id => record[0] ,:gender => record[3] ,                                            
                       :dob => record[4] , :first_name => record[1] ,                                
                       :last_name => record[2],:national_id => record[7],
                       :outcome => record[6], :outcome_date => record[5] }
        end

    end
    return patients
  end


  protected

  def self.sms_status(start_date,end_date)                                 
    db_name = YAML.load(File.open(File.join(RAILS_ROOT, "config/database.yml"), "r"))["bart"]["database"]
    sms_type_id = SmsType.find_by_name("Outbox").id
    records = Sms.find(:all,:joins =>"INNER JOIN #{db_name}.person p 
      ON p.person_id = sms.person_id
      INNER JOIN #{db_name}.person_name n ON p.person_id=n.person_id                                 
      INNER JOIN #{db_name}.patient_identifier i ON i.patient_id = sms.person_id 
      AND i.identifier_type = (SELECT patient_identifier_type_id 
      FROM #{db_name}.patient_identifier_type pi WHERE pi.name = 'National id')
      INNER JOIN #{db_name}.users u ON u.user_id=sms.provider_id",
      :conditions =>["sms_type_id=? AND delivered = 0",sms_type_id],
      :select =>"sms.person_id,n.given_name,n.family_name, p.gender, 
      p.birthdate , sms.message , sms.delivered , sms.number, sms.date_created sent_date ,
      u.username sender,i.identifier national_id",
      :order => "sms.date_created DESC")

    (records || []).collect do |r|
      [r.person_id,r.given_name , r.family_name , r.gender,
       r.birthdate , r.sent_date , r.delivered ,r.national_id,
       r.sender , r.message , r.number,r.delivered]
    end
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
    dispensing = EncounterType.find_by_name("DISPENSING").id
    amount_dispensed_concept_id = ConceptName.find_by_name("Amount dispensed").concept_id
    db = YAML.load(File.open(File.join(RAILS_ROOT, "config/database.yml"), "r"))[RAILS_ENV]

    records = Observation.find_by_sql("SELECT e.patient_id,n.given_name,n.family_name, 
p.gender, p.birthdate , DATE(e.encounter_datetime) AS visit_date,
#{db['database']}.prescribed_days_missed(DATE(orders.start_date),DATE('#{end_date}'),equivalent_daily_dose,quantity) AS days_over_due,
identifier AS national_id
FROM obs 
INNER JOIN encounter e ON e.encounter_id = obs.encounter_id 
AND e.encounter_datetime=(SELECT MAX(x.encounter_datetime) FROM encounter x WHERE x.patient_id=e.patient_id)
INNER JOIN drug d ON d.drug_id = obs.value_drug and d.concept_id IN(SELECT s.concept_id FROM concept_set s WHERE (concept_set = 1085))
INNER JOIN orders ON orders.order_id = obs.order_id
INNER JOIN drug_order od ON od.order_id = orders.order_id
INNER JOIN person p ON p.person_id=e.patient_id
INNER JOIN person_name n ON p.person_id=n.person_id
INNER JOIN patient_identifier i ON i.patient_id = e.patient_id AND i.identifier_type = (SELECT patient_identifier_type_id FROM patient_identifier_type pi WHERE pi.name = 'National id')
WHERE e.encounter_type = #{dispensing} and obs.concept_id =  #{amount_dispensed_concept_id}
GROUP BY e.patient_id
HAVING days_over_due >= 21
ORDER BY e.encounter_datetime DESC,e.date_created DESC")   
      (records || []).collect do |r|
        [r.patient_id,r.given_name , r.family_name , r.gender,
         r.birthdate , r.visit_date , r.days_over_due ,r.national_id]
      end
    end

    def self.traced_outcome_status(start_date,end_date)                                               
      db = YAML.load(File.open(File.join(RAILS_ROOT, "config/database.yml"), "r"))["bart"]["database"]
      
      records = TraceOutcomeType.find(:all,               
      :select => "p.patient_id,n.given_name,n.family_name,ps.gender, ps.birthdate,
      trace_outcome_type.name,p.outcome_date,identifier national_id",
      :joins => "INNER JOIN patient_trace_outcome p                              
      ON trace_outcome_type.id = p.trace_outcome_id                             
      AND p.id = (SELECT id FROM patient_trace_outcome WHERE patient_id = p.patient_id
      AND p.outcome_date = outcome_date ORDER BY date_created DESC LIMIT 1)
      INNER JOIN #{db}.person ps ON ps.person_id = p.patient_id
      INNER JOIN #{db}.person_name n ON ps.person_id=n.person_id
      INNER JOIN #{db}.patient_identifier i ON i.patient_id = ps.person_id
      AND i.identifier_type = (SELECT patient_identifier_type_id 
      FROM #{db}.patient_identifier_type pi WHERE pi.name = 'National id')",
      :conditions =>["p.outcome_date >= ? AND p.outcome_date <=?", 
      start_date , end_date]) 
                             
      (records || []).collect do |r|
        [r.patient_id,r.given_name , r.family_name , r.gender,
         r.birthdate , r.outcome_date , r.name , r.national_id]
      end
  end 
end
