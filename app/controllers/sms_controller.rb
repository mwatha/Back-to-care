class SmsController < ApplicationController
  def inbox
    sms = Sms.new()
    sms.sms_type_id = SmsType.find_by_name("Outbox")
    sms.person_id = params[:person_id]
    sms.provider_id = User.current_user
    sms.message = params[:sms]
    sms.number = params[:number]
    success = sms.save

    #here is where we send the saved text meeage to the patient
    `adb shell am start -a android.intent.action.SENDTO -d sms:#{sms.number} --es sms_body "#{sms.message}" --ez exit_on_sent true && adb shell input keyevent 22 && adb shell input keyevent 66`

    render :text => "sent #{success}" and return
  end
  
  def update_sms_thred
    @sms = Sms.find(:all,:conditions =>["person_id=?",params[:id]])
    @html = '<table id="sent_msg">'
    @sms.map do |sms|
      @html+=<<EOF
<tr>                                                                            
  <th class="delivered_#{sms.delivered}">#{sms.number} (#{sms.date_created.to_date})</th>                          
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
