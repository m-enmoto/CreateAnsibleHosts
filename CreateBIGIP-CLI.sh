#!/bin/bash

###define
. ./define.sh

###check bigip.conf
echo
echo check bigip.conf 
echo ---------

cnt=0
while [ $cnt -lt $NumberOfWeb ] 
do
    cnt=`expr $cnt + 1`
    ip=$(sed -n ${cnt}p iplist)
    echo grep ${ip/192.168.28/192.168.80} bigip.conf \; \\
done

echo grep ${GlobalIP} bigip.conf

echo
echo ============
echo tmsh command 
echo ============
echo

###node
echo node
echo ---------

cnt=0
while [ $cnt -lt $NumberOfWeb ] 
do
    cnt=`expr $cnt + 1`
    ip=$(sed -n ${cnt}p iplist)
    echo create ltm node ${ip/192.168.28/192.168.80} { screen ${env}${cnt} } 
done

echo
###pool_http
echo "http & SSL endpoint BIGIP"
echo ---------

poolname=${env}_pool_http

echo create ltm pool $poolname

cnt=0
while [ $cnt -lt $NumberOfWeb ] 
do
    cnt=`expr $cnt + 1`
    ip=$(sed -n ${cnt}p iplist)                                                     
    echo modify ltm pool ${poolname} members add { ${ip/192.168.28/192.168.80}:http }
done

echo modify ltm pool ${poolname} monitor http

echo
###pool_https
echo SSL endpoint Server
echo ---------

poolname=${env}_pool_https
                                                                                                      
echo create ltm pool $poolname

cnt=0
while [ $cnt -lt $NumberOfWeb ] 
do
    cnt=`expr $cnt + 1`
    ip=$(sed -n ${cnt}p iplist)
    echo modify ltm pool ${poolname} members add { ${ip/192.168.28/192.168.80}:https }
done

echo modify ltm pool ${poolname} monitor https

echo

###Virtual Server
echo SSL endpoint BIGIP
echo ---------
poolname=${env}_pool_http
echo create ltm virtual ${env}_HTTPS destination ${GlobalIP}:https pool ${poolname}
echo
echo SSL endpoint Server
echo ---------
poolname=${env}_pool_https
echo create ltm virtual ${env}_HTTPS destination ${GlobalIP}:https pool ${poolname}
