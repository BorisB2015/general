#!/bin/bash

uniqueID=99
serviceName=rhgs-borisb1
location="South Central US"
password='<replace in local copy>'
imageName="RHEL72gs1"

createCloudService()
{
  azure service create --serviceName $serviceName --location $location
}

createPrimaryNodes()
{
  for i in 1 2 3 4
  do
    azure vm create --vm-name rhgs$i --availability-set AS1 -S 10.20.${uniqueID}.$i --vm-size Standard_D1_v2 --virtual-network-name rhgs-vnet --ssh 5000$i --connect $serviceName $imageName  rhgsuser $password
    azure vm disk attach-new -d $serviceName.cloudapp.net rhgs$i 10
  done
}

createSecondaryNodes()
{
  for i in 5 6
  do
    azure vm create --vm-name rhgs$i --availability-set AS1 -S 10.20.${uniqueID}.$i --vm-size Standard_D1_v2 --virtual-network-name rhgs-vnet --ssh 5000$i --connect $serviceName $imageName  rhgsuser $password
    azure vm disk attach-new -d $serviceName.cloudapp.net rhgs$i 10
  done
}

createLinuxNode()
{
    i=7
    azure vm create --vm-name linux-client --availability-set AS1 -S 10.20.${uniqueID}.$i --vm-size Standard_D1_v2 --virtual-network-name rhgs-vnet --ssh 5000$i --connect $serviceName rhel71-ver1  rhgsuser $password
}

createWindowsNode()
{
    i=8
    azure vm create --vm-name win-client --availability-set AS1 -S 10.20.${uniqueID}.$i --vm-size Standard_D1_v2 --virtual-network-name rhgs-vnet --rdp 5000$i --connect $serviceName a699494373c04fc0bc8f2bb1389d6106__Win2K8R2SP1-Datacenter-20160125-en.us-127GB.vhd  rhgsuser $password
}

if [ "$1" != "" ]
then
  uniqueID=$1
else
  echo "Error: pass cluster id 1 through 50 !"
  exit
fi

# Ensure we are in ASM mode
azure config mode asm

createCloudService
createPrimaryNodes
#createSecondaryNodes
#createLinuxNode
#createWindowsNode