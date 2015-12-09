#!/bin/bash

###define
. ./define.sh

###
cnt=0
while [ $cnt -lt $NumberOfWeb ] 
do
    cnt=`expr $cnt + 1`
    pingdest=$(sed -n ${cnt}p webip.list)


#    echo ping -c 4 192.168.28.$(sed -n ${cnt}p iplist.txt) 
#        ping -c 2 192.168.28.$(sed -n ${cnt}p iplist.txt) 
         ping -c 2 ${pingdest} 

#    echo ping -c 2 192.168.80.$(sed -n ${cnt}p iplist.txt) 
         ping -c 2 ${pingdest/192.168.28/192.168.80} 

done
