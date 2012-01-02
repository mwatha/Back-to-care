class IssuesController < ApplicationController
  def index
    @issue = params[:id].capitalize
  end

  def quick_search
    name = params[:search_str] ; gender = params[:gender].first rescue ""
    person = PatientService.find_patients_by_name_and_gender(name , gender)
    @html = ""
    person.each do | person |
      demographics = PatientService.demographics(person)                                                                     
      @html+=<<EOF
<tr class="patient_info">                                                       
  <td>#{"&nbsp;"*2}#{demographics[:national_id]}</td>                                                      
  <td>#{demographics[:first_name]}</td>                                                                     
  <td>#{demographics[:last_name]}</td>                                                                     
  <td>#{demographics[:gender]}</td>                                                                     
  <td>#{demographics[:dob]}</td>                                                                     
  <td>&nbsp;</td>                                                                     
  <td>&nbsp;</td>                                                                     
  <td>&nbsp;</td>                                                                     
</tr>                                                                           
EOF
    end
  
    @html+="</tbody></table>"   
    render :partial => 'quick_search', :object => @html ; return  
  end

end
