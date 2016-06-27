
# On All Nodes
sudo subscription-manager register --username='<USERNAME>' --password='<PASSWORD>' --auto-attach --force
sudo passwd root
# turn off fwalls or punch holes
sudo iptables -I INPUT -p all -s 10.20.2.1 -j ACCEPT
sudo iptables -I INPUT -p all -s 10.20.2.2 -j ACCEPT
sudo iptables -I INPUT -p all -s 10.20.2.3 -j ACCEPT
sudo iptables -I INPUT -p all -s 10.20.2.4 -j ACCEPT


# Node 1 only

sudo yum -y install \
    https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-7.noarch.rpm

sudo yum install ansible -y

sudo bash

ssh-keygen
for i in 1 2 3 4; do ssh-copy-id root@rhgs$i; done

gdeploy -vv -c ~rhgsuser/gdeploy.conf -k

# Node 1 tests

# gluster vol create glustervol replica 2 rhgs1:/gluster/brick1 rhgs2:/gluster/brick1 rhgs3:/gluster/brick1 rhgs4:/gluster/brick1 force

# Creating files
mkdir /mnt/gfs/test
cd /mnt/gfs/test/
for i in `seq 1 100`; do echo hellp$i > file$i; done

