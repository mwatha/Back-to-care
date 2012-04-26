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
    (1.upto(3)).each do |n|
    `adb shell am start -a com.googlecode.android_scripting.action.LAUNCH_BACKGROUND_SCRIPT -n com.googlecode.android_scripting/.activity.ScriptingLayerServiceLauncher -e com.googlecode.android_scripting.extra.SCRIPT_PATH /sdcard/sl4a/scripts/sms_read.py && adb pull /sdcard/msgs/inbox.txt`
    end

    File.open(File.join(RAILS_ROOT, "inbox.txt"), File::RDONLY).readlines.each do |line|
      par = line.sub("\n","").strip.split(";")
      
      msg_id = par[0].split(":")[1].strip rescue nil
      body = par[1].split(":")[1].strip rescue nil
      phone_number = par[2].split(":")[1].strip rescue nil
     
      next if msg_id.blank?
       
      msg_exist = Sms.find(:first,:conditions =>["message = ?","#{msg_id}::#{body}"]) 
      if msg_exist.blank?
        person_id = PersonAttribute.find(:first,
          :conditions =>["value LIKE (?)",
          "%#{phone_number.sub('+265','')}%"]).person_id rescue nil

        next if person_id.blank?

        sms = Sms.new()
        sms.sms_type_id = SmsType.find_by_name("Inbox").id
        sms.person_id = person_id
        sms.delivered = 1
        sms.provider_id = 1
        sms.message = "#{msg_id}::#{body}"
        sms.number = phone_number
        sms.save rescue false
      end
      #`rm #{RAILS_ROOT}inbox.txt`
    end
    render :text => "updated inbox...." and return
  end
 
  
  def update_sms_thred
    @sms = Sms.find(:all,:conditions =>["person_id=?",params[:id]],:order =>"date_created DESC,id DESC")
    @html = '<table id="sent_msg">'
    @sms.map do |sms|
      if sms.message.match(/::/)
        message = sms.message.split("::")[1].to_s rescue sms.message
      else
        message = sms.message
      end
      @html+=<<EOF
<tr>                                                                            
  <th class="delivered_#{sms.delivered} incoming_#{sms.sms_type_id}">#{sms.number} (#{sms.date_created.to_date})</th>                          
</tr>                                                                           
<tr>                                                                            
  <td class='line_bottom'>#{message}</td>                                   
</tr>
EOF
    end
    @html+= "</table>"
    render :text => @html and return
  end

end
