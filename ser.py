import serial
from datetime import datetime

a=serial.Serial('/dev/ttyACM0',9600)

while 1:
  time1=datetime.now().strftime('%H:%M:%S')
  b=a.readline().replace('\r\n','').split(', ')
  try:
    sd=[float(i) for i in b]
    print time1, sd
  except:
    print time1,([0,0,0,0,0])
