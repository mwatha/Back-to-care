class IssuesController < ApplicationController
  def index
    @issue = params[:id].capitalize rescue nil
  end

  def quick_search
    name = params[:search_str].strip 
    report = ""
    gender = params[:gender].strip.first rescue ""
    patients = PatientService.find_patients_by_name_and_gender(name , gender)
    @html = ""
    patients.each do | person |
      demographics = PatientService.demographics(person)                                                                     
      @html+=<<EOF
<tr class="patient_info">                                                       
  <td>#{"&nbsp;"*2}#{demographics[:national_id]}</td>                                                      
  <td>#{demographics[:first_name]}</td>                                                                     
  <td>#{demographics[:last_name]}</td>                                                                     
  <td>#{demographics[:gender]}</td>                                                                     
  <td>#{demographics[:dob]}</td>                                                                     
  <td>#{demographics[:last_visit_date]}</td>                                                                     
  <td><a href="/issues/show?id=#{person.id}&title=#{report}" class="show_details">Show</a>|
  <a href="/issues/sms/#{person.id}" class="show_details">Send sms</a>
  </td>                                                                     
</tr>                                                                           
EOF
    end
  
    @html+="</tbody></table>"   
    render :partial => 'quick_search', :object => @html ; return  
  end

  def show
    @demographics = PatientService.demographics(Person.find(params[:id]))                                                                    
    @sms = Sms.find(:all,:conditions =>["person_id=?",params[:id]])
    @report = params[:title]
  end

  def report
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date
    report = params[:id]
    patients = PatientService.report(report , start_date , end_date)
    @html = ""
    patients.each do | demographics |
      @html+=<<EOF
<tr class="patient_info">                                                       
  <td>#{"&nbsp;"*2}#{demographics[:national_id]}</td>                                                      
  <td>#{demographics[:first_name]}</td>                                                                     
  <td>#{demographics[:last_name]}</td>                                                                     
  <td>#{demographics[:gender]}</td>                                                                     
  <td>#{demographics[:dob]}</td>                                                                     
  <td>#{demographics[:last_visit_date]}</td>                                                                     
  <td><a href="/issues/show?id=#{demographics[:person_id]}&title=#{report}" class="show_details">Show</a>|
  <a href="/issues/sms/#{demographics[:person_id]}" class="show_details">Send sms</a>
  </td>                                                                     
</tr>                                                                           
EOF
    end
  
    @html+="</tbody></table>"   
    render :partial => 'quick_search', :object => @html ; return  
  end

end
