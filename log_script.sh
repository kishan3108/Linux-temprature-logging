#!/bin/bash 
# Log temperature over some time  interval given as days, hours, minutes or seconds.
# enter the variables according to your usage in the following seciton :
duration="$1"  #duration format is  ndnhnmns where n is some number and d is day,
# h is hours, m is minutes and s is seconds. For example, 4d , 4d5h30m , 5m30s, 6h30m30s are all valid.

step="$2"
#----------------------------------------------------------------------
#starting time taken as current
dt=$(date '+%Y-%m-%dT%H:%M:%S');
#et=$(date '+%Y-%m-%dT%H:%M:%S');

#----------------------------------------------------------------------
a=$(dateutils.dadd $dt  $duration )
b=$(dateutils.ddiff $dt $a -f '%S')
echo $a $b

ntimes=$((b/step))
echo $ntimes


echo "logging...";
rm t_log.txt
nms=0
while [  $nms -lt $ntimes ];  do
        sensors | grep -A 0  'Core' | cut -c17-20 |tr "\n" "\t" >> temp.txt
        nvidia-smi | grep -A 0 'Default' | cut -c8-10 | tr "\n" "\t" >>temp.txt
        top -bn 2 -d 0.01 | grep '^%Cpu' | tail -n 1 | gawk '{print $2+$4+$6}' | tr "\n" "\t" >> temp.txt
        nvidia-smi -a -q | grep -A 0 'Gpu' | cut -c38-40 | tr "\n" "\t" >> temp.txt
        nvidia-smi | grep -A 0 'Default' | cut -c21-23 | tr "\n" "\t" >> temp.txt
        nvidia-smi | grep -A 0 'Default' | cut -c2-4 | tr "\n" "\t" >> temp.txt
        
        let nms=nms+1
        sleep  $step
        now=$(date +"%m/%d/%Y %T")
#       echo $now
        echo -e "$(cat temp.txt)""\t$now"  >> t_log.txt
        rm temp.txt
done


#plotting using gnuplot to get a beautiful plot. 
day=86400 #different x-axis for different  time duration. A day = 86400 seconds

fcode=$(date "+%Y-%m-%d_%H%M%S") # generate a time stamp 
#echo $fcode

if [[ "$b" > "$day" ]]
then
        gnuplot -e "filename='temp_plot_$fcode'" plot_day
else
        gnuplot -e "filename='temp_plot_$fcode'" plot_time
fi
#end-of-script---------------------------------------------------------
