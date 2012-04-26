import android

droid = android.Android()
print droid.smsGetMessages(False,'inbox', None)
msgs = droid.smsGetMessageIds(False, 'inbox')[1]
filename = "inbox.txt"
msglist = []

for msg in msgs:
    # print droid.smsGetMessageById[msg]
    msglist.append(droid.smsGetMessageById[msg])

FILE = open(filename, "w")

FILE.writelines(msglist)

FILE.close()
