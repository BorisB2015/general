
# Kickstart for creating Red Hat Gluster Storage Azure VM

#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512

# Use CDROM installation media
cdrom

# Use non-graphical install
text

# Do not run the Setup Agent on first boot
firstboot --disable

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp 
# network  --hostname=localhost.localdomain

# Root password
rootpw --iscrypted $6$WZU8kTek1AT8KFG.$Q2jnF9/C7GyhkXMlqbGmrzCNU.relnVuPqeAWPUW14tP5T2/TCsjT0lAEKV/UK4QvXydUls4pDZugvu73u6EG.

# System services
services --enabled="sshd,NetworkManager"

# System timezone
timezone Etc/UTC --isUtc --ntpservers 0.rhel.pool.ntp.org,1.rhel.pool.ntp.org,2.rhel.pool.ntp.org,3.rhel.pool.ntp.org

# Partition clearing information
clearpart --all --initlabel

# Clear the MBR
zerombr

# Disk partitioning information
part /boot --fstype="xfs" --size=500
part / --fstype="xfs" --size=1 --grow --asprimary

# System bootloader configuration
bootloader --location=mbr

# Firewall configuration
# firewall --disabled

# Enable SELinux
selinux --enforcing

# Don't configure X
skipx

# Power down the machine after install
poweroff

%packages
@^Default_Gluster_Storage_Server
@RH-Gluster-Core
@RH-Gluster-Swift
@RH-Gluster-Tools
@base
@core
@scalable-file-systems
kexec-tools
chrony
sudo
parted
-dracut-config-rescue


%end

%post --log=/dev/console

#!/bin/bash

# force hyperv drivers (maybe only needed when unattended installing under qemu)
# do this early on so that any kernel updated via yum is built w/ hv drivers
echo 'add_drivers+="hv_vmbus hv_netvsc hv_storvsc"' >> /etc/dracut.conf
echo "kickstart_post: begin rebuilding kernel"
dracut -f -v
echo "kickstart_post: finished rebuilding kernel"

# subscribe
subscription-manager register --username='<USERNAME>' --password='<PASSWORD>' --auto-attach --force
yum update -y

# Install gdeploy dependency
yum install PyYAML -y

# Install WALinuxAgent
subscription-manager repos --enable=rhel-7-server-extras-rpms
yum install -y WALinuxAgent

systemctl enable waagent.service

subscription-manager unregister

# Modify yum
echo "http_caching=packages" >> /etc/yum.conf

# Set the network file
echo "NETWORKING=yes" > /etc/sysconfig/network

# Configure swap in WALinuxAgent
sed -i 's/^\(ResourceDisk\.EnableSwap\)=[Nn]$/\1=y/g' /etc/waagent.conf
sed -i 's/^\(ResourceDisk\.SwapSizeMB\)=[0-9]*$/\1=2048/g' /etc/waagent.conf

# Set the cmdline
sed -i 's/^\(GRUB_CMDLINE_LINUX\)=".*"$/\1="console=ttyS0 earlyprintk=ttyS0 rootdelay=300"/g' /etc/default/grub

# Enable SSH keepalive
sed -i 's/^#\(ClientAliveInterval\).*$/\1 180/g' /etc/ssh/sshd_config

# Build the grub cfg
grub2-mkconfig -o /boot/grub2/grub.cfg

# Configure network
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
TYPE=Ethernet
USERCTL=no
PEERDNS=yes
IPV6INIT=no
NM_CONTROLLED=yes
EOF

echo "ANACONDA FINISHED"

# Configure password policy
cat /etc/security/pwquality.conf | sed -e 's/^#.* minclass.*=.*[0-9]/minclass = 3/g' -e 's/^#.*minlen.*=.*[0-9]*/minlen = 6/g' -e 's/^#.*dcredit.*=.*[0-9]/dcre
dit = 0/g' -e 's/^#.*ucredit.*=.*[0-9]/ucredit = 0/g' -e 's/^#.*lcredit.*=.*[0-9]/lcredit = 0/g' -e 's/^#.*ocredit.*=.*[0-9]/ocredit = 0/g' > /etc/security/pwq
uality.conf.new
mv /etc/security/pwquality.conf /etc/security/pwquality.conf.bak
mv /etc/security/pwquality.conf.new /etc/security/pwquality.conf
chmod 644 /etc/security/pwquality.conf


# clean up logs
rm -f /prepare-rhui-installation.sh
rm -f /WALinuxAgent-2.0.16-1.el7.noarch.rpm
rm -f /tmp/ks*
rm -f /tmp/yum.log
rm -f /root/anaconda-ks.cfg
rm -f /var/log/prepare-rhui-installation.log
rm -f /var/log/anaconda/*
rm -rf /var/log/rhsm/*
rm -f /var/log/messages
rm -f /var/log/dmesg

rm /etc/rc3.d/S99cleansh
rm /etc/init.d/cleansh

# deprovision
/sbin/waagent -force -deprovision

# Clear bash history
export HISTSIZE=0
rm -f /root/.bash_history


%end