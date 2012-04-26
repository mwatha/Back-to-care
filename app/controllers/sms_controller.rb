class SmsController < ApplicationController
  def inbox
    #here is where we send the saved text meeage to the patient
    number = params[:number]
    if number.first == '0'
      number = "+265#{number[1..number.length]}"
    else
      number = "+265#{number}"
    end
    
    sms = Sms.new()
    sms.sms_type_id = SmsType.find_by_name("Outbox")
    sms.person_id = params[:person_id]
    sms.provider_id = User.current_user
    sms.message = params[:sms]
    sms.number = number
    success = sms.save

    `echo '#{number}:#{sms.message}' > #{RAILS_ROOT}/sms/outbox.txt`

    (1.upto(1)).each do |n|
      `adb push #{RAILS_ROOT}/sms/outbox.txt /sdcard/msgs && adb shell am start -a com.googlecode.android_scripting.action.LAUNCH_BACKGROUND_SCRIPT -n com.googlecode.android_scripting/.activity.ScriptingLayerServiceLauncher -e com.googlecode.android_scripting.extra.SCRIPT_PATH /sdcard/sl4a/scripts/sms_send.py`
    end
    render :text => "sent #{success}" and return
  end
 
 
  def outbox
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
