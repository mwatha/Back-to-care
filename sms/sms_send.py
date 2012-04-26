import android

droid = android.Android()
infile = open("/sdcard/msgs/outbox.txt", "r")

while infile:
	line = infile.readline()
	fields = line.split(":")
	if len(fields) > 0:
		print "To: " + fields[0] + "; Msg: " + fields[1]
		droid.smsSend(fields[0], fields[1])

