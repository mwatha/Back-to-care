import android

droid = android.Android()
msgs = droid.smsGetMessageIds(False, 'inbox')[1]
filename = "/sdcard/msgs/inbox.txt"
msglist = []
FILE = open(filename,"w")

for msg in msgs:
    print droid.smsGetMessageById(msg)
    FILE.write("id: " + str(droid.smsGetMessageById(msg)[0]) + "; body: " + droid.smsGetMessageById(msg)[1]["body"] + "; address: " + str(droid.smsGetMessageById(msg)[1]["address"]) + " \n")

FILE.close()
