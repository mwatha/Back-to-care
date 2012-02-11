class SmsController < ApplicationController
  def inbox
    sms = Sms.new()
    sms.sms_type_id = 1
    sms.person_id = params[:person_id]
    sms.provider_id = 1
    sms.message = params[:sms]
    sms.number = params[:number]
    sms.date_created = Time.now()
    success = sms.save
    render :text => "sent #{success}" and return
  end
  
  def update_sms_thred
    @sms = Sms.find(:all,:conditions =>["person_id=?",params[:id]])
    @html = '<table id="sent_msg">'
    @sms.map do |sms|
      @html+=<<EOF
<tr>                                                                            
  <th>#{sms.number} (#{sms.date_created.to_date})</th>                          
</tr>                                                                           
<tr>                                                                            
  <td class='line_bottom'>#{sms.message}</td>                                   
</tr>
EOF
    end
    @html+= "</table>"
    render :text => @html and return
  end

end
