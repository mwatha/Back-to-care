module ReportsHelper

  def build_table(patients , title)
    @html =<<EOF
<table id="patient_data">
<thead>                                                                         
<tr id = 'table_head_tr'>                                                          
<th id="th1">#{"&nbsp;"*2}National ID</th>                                  
<th id="th2" style="width:200px;">First name</th>                             
<th id="th3" style="width:200px;">Last name</th>                              
<th id="th4" style="width:85px;">Sex</th>                                     
<th id="th5" style="width:150px;">DOB</th>                                    
<th id="th6" style="width:150px;">Last visit date</th>                        
<th id="th7" style="width:100px;">&nbsp;</th>                                 
</tr>                                                                           
</thead>
<tbody>
EOF

    patients.each do | demographics |
      @html+=<<EOF
<tr class="patient_info">                                                       
  <td>#{"&nbsp;"*2}#{demographics[:national_id]}</td>                                                      
  <td>#{demographics[:first_name]}</td>                                                                     
  <td>#{demographics[:last_name]}</td>                                                                     
  <td>#{demographics[:gender]}</td>                                                                     
  <td>#{demographics[:dob]}</td>                                                                     
  <td>#{demographics[:last_visit_date]}</td>                                                                     
  <td><a href="/issues/show?id=#{demographics[:person_id]}&title=#{title}" class="show_details">Show</a>|
  <a href="/issues/sms/#{demographics[:person_id]}" class="show_details">Send sms</a>
  </td>                                                                     
</tr>                                                                           
EOF
    end
  
    @html+='</tbody></table>'   
  end

end
