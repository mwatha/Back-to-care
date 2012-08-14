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
   <td id='#{demographics[:person_id]}' class='patient_ids'>#{"&nbsp;"*2}#{demographics[:national_id]}</td>                                                      
  <td>#{demographics[:first_name]}</td>                                                                     
  <td>#{demographics[:last_name]}</td>                                                                     
  <td>#{demographics[:gender]}</td>                                                                     
  <td>#{demographics[:dob]}</td>                                                                     
  <td>#{demographics[:last_visit_date]}</td>                                                                     
  <td><a href="/issues/show?id=#{demographics[:person_id]}&title=#{title}" class="show_details">Show</a>|
  <a href="javascript:sendText(#{demographics[:person_id]})" class="show_details">Send sms</a>
  </td>                                                                     
</tr>                                                                           
EOF
    end
  
    @html+='</tbody></table>'   
  end

  def sms_status_table(patients , title)
    @html =<<EOF
<table id="patient_data">
<thead>                                                                         
<tr id = 'table_head_tr'>                                                          
<th id="th1">#{"&nbsp;"*2}National ID</th>                                  
<th id="th2">First name</th>                             
<th id="th3">Last name</th>                              
<th id="th4">Sex</th>                                     
<th id="th5">DOB</th>                                    
<th id="th6">Message</th>                        
<th id="th7">Sent to</th>                        
<th id="th7">Sender</th>                        
<th id="th9">Sent-date</th>                        
<th id="th10">Delivered</th>                        
<th id="th11">&nbsp;</th>                                 
</tr>                                                                           
</thead>
<tbody>
EOF

    patients.each do | demographics |
      @html+=<<EOF
<tr class="patient_info" style="vertical-align: top;">                                                       
  <td id='#{demographics[:person_id]}' class='patient_ids'>#{"&nbsp;"*2}#{demographics[:national_id]}</td>                                                      
  <td>#{demographics[:first_name]}</td>                                                                     
  <td>#{demographics[:last_name]}</td>                                                                     
  <td>#{demographics[:gender]}</td>                                                                     
  <td>#{demographics[:dob]}</td>                                                                     
  <td>#{demographics[:message]}</td>                                                                     
  <td>#{demographics[:number]}</td>                                                                     
  <td>#{demographics[:sender]}</td>                                                                     
  <td>#{demographics[:send_date].to_date rescue nil}</td>                                                                     
  <td>#{demographics[:status]}</td>                                                                     
  <td><a href="/issues/show?id=#{demographics[:person_id]}&title=#{title}" class="show_details">Show</a>|
  <a href="javascript:sendText(#{demographics[:person_id]})" class="show_details">Send sms</a>
  </td>                                                                     
</tr>                                                                           
EOF
    end
  
    @html+='</tbody></table>'   
  end

  def traced_outcomes(patients , title)                                             
    @html =<<EOF                                                                
<table id="patient_data">                                                       
<thead>                                                                         
<tr id = 'table_head_tr'>                                                          
<th id="th1">#{"&nbsp;"*2}National ID</th>                                      
<th id="th2" style="width:200px;">First name</th>                               
<th id="th3" style="width:200px;">Last name</th>                                
<th id="th4" style="width:85px;">Sex</th>                                       
<th id="th5" style="width:150px;">DOB</th>                                      
<th id="th99" style="width:325px !important;">Outcome</th>                          
<th id="th6" style="width:85px;">Outcome date</th>                          
<th id="th7" style="width:100px;">&nbsp;</th>                                   
</tr>                                                                           
</thead>                                                                        
<tbody>
EOF
                                                                             
                                                                                
    patients.each do | demographics |                                           
      @html+=<<EOF                                                              
<tr class="patient_info">                                                       
  <td id='#{demographics[:person_id]}' class='patient_ids'>#{"&nbsp;"*2}#{demographics[:national_id]}</td>                                                      
  <td>#{demographics[:first_name]}</td>                                                                     
  <td>#{demographics[:last_name]}</td>                                                                     
  <td>#{demographics[:gender]}</td>                                                                     
  <td>#{demographics[:dob]}</td>                                                                     
  <td>#{demographics[:outcome]}</td>                                                                     
  <td>#{demographics[:outcome_date]}</td>                                                                     
  <td><a href="/issues/show?id=#{demographics[:person_id]}&title=#{title}" class="show_details">Show</a>|
  <a href="javascript:sendText(#{demographics[:person_id]})" class="show_details">Send sms</a>
  </td>                                                                         
</tr>                                                                           
EOF
                                                                         
    end                                                                         
                                                                                
    @html+='</tbody></table>'                                                   
  end         
  
end
