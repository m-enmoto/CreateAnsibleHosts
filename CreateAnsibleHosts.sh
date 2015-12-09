#!/bin/sh

#####define

. ./define.sh

#####function

function HostsIP() {
cntA=0
while read webiplist
    do
    cntA=$(( cntA + 1 ))
    echo [web${cntA}]
    echo "$webiplist ansible_ssh_user=$sshuser ansible_ssh_private_key_file=$sshkey"
done < $idlist
}

function HostsVars() {
cntA=0
while [ $cntA -lt $NumberOfWeb ] 
do
    cntA=$(( cntA + 1 ))
    echo [web${cntA}:vars]
    echo host_name=${env}web${cntA}
done
}

function GroupsVars() {
cat <<EOT

[web:children]
$(for i in `seq $NumberOfWeb` ; do echo web$i ; done)

[web:vars]
db_ip=$db_ip
nfs_ip=$nfs_ip
memcached_ip=$memcached_ip
mail_ip=$mail_ip

[dbvip]
$db_ip ansible_ssh_user=$sshuser ansible_ssh_private_key_file=$sshkey

[memcached]
$memcached_ip ansible_ssh_user=$sshuser ansible_ssh_private_key_file=$sshkey

[size_large:children]
web
db

[mode_production:children]
web
db

EOT
}


function DBhosts() {
cat <<EOT

[db1]
$db1_ip ansible_ssh_user=$sshuser ansible_ssh_private_key_file=$sshkey
[db2] 
$db2_ip ansible_ssh_user=$sshuser ansible_ssh_private_key_file=$sshkey
[db:children]
db1
db2
[db1:vars] 
host_name=${env}db1
[db2:vars]
host_name=${env}db2

EOT
}

function DBparams() {
cat <<EOT
[db:vars]
### /etc/hosts /etc/ha.d/ha.cf eth1
mail_ip=${mail_ip}
mail_name=${mail_name}
#
db1_name=${env}db1
db1_ip=${db1_ip}
db1_ip2=${db1_ip2}
#
db2_name=${env}db2
db2_ip=${db2_ip}
db2_ip2=${db2_ip2}
#
db_name=${db_name}
db_ip=${db_ip}

### /etc/sysconfig/network
gateway_ip=${gateway_ip}

### /etc/ha.d/loadreplace.crm
cidr_netmask=${cidr_netmask}
nic=${nic}
PGbin=${PGbin} 
fstype=${fstype} 

### /etc/exports
exports=${exports} 

### postgresql.conf
max_connections=${max_connections} 
shared_buffers=${shared_buffers} 
work_mem=${work_mem} 
maintenance_work_mem=${maintenance_work_mem} 

EOT
}

#####function exec

HostsIP >> $dir
HostsVars >> $dir
GroupsVars >> $dir
DBhosts >> $dir
DBparams  >> $dir
