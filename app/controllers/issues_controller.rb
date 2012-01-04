class IssuesController < ApplicationController
  def index
    @issue = params[:id].capitalize
  end

  def quick_search
    name = params[:search_str].strip 
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
  <td><a href="/issues/show/#{person.id}" class="show_details">Show</a>|
  <a href="/issues/sms/#{person.id}" class="show_details">Send sms</a>
  </td>                                                                     
</tr>                                                                           
EOF
    end
  
    @html+="</tbody></table>"   
    render :partial => 'quick_search', :object => @html ; return  
  end

end
