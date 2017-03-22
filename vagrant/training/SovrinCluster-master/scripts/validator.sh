#!/bin/bash

HOSTNAME=$1
NODEPORT=$2
CLIENTPORT=$3

#--------------------------------------------------------
echo 'Setting Up Networking'
cp /vagrant/etc/hosts /etc/hosts
perl -p -i -e 's/(PasswordAuthentication\s+)no/$1yes/' /etc/ssh/sshd_config
service sshd restart

#--------------------------------------------------------
echo "Installing Required Packages"
apt-get update
apt-get install -y software-properties-common python-software-properties
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D82D8E35
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EAA542E8
add-apt-repository "deb https://repo.evernym.com/deb xenial master"
add-apt-repository "deb https://repo.sovrin.org/deb xenial master"
apt-get update
#DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y dialog figlet python-pip python3-pip python3.5-dev libsodium18 unzip make screen sovrin-node tmux vim wget

#--------------------------------------------------------
echo 'Setting Up Sovrin Node'
su - sovrin -c "init_sovrin_node $HOSTNAME $NODEPORT $CLIENTPORT"
systemctl start sovrin-node
systemctl enable sovrin-node
systemctl status sovrin-node.service
su - sovrin -c "generate_sovrin_pool_transactions --nodes 4 --clients 4 --ips '10.20.30.201,10.20.30.202,10.20.30.203,10.20.30.204'"

#--------------------------------------------------------
echo 'Fixing Bugs'
if grep -Fxq '[Install]' /etc/systemd/system/sovrin-node.service
then
  echo '[Install] section is present in sovrin-node target'
else 
  perl -p -i -e 's/\\n\\n/[Install]\\nWantedBy=multi-user.target\\n/' /etc/systemd/system/sovrin-node.service
fi
chmod -x /etc/systemd/system/orientdb.service
if grep -Fxq 'SendMonitorStats' /home/sovrin/.sovrin/sovrin_config.py
then
  echo 'SendMonitorStats is configured in sovrin_config.py'
else
  echo 'SendMonitorStats = False' > /home/sovrin/.sovrin/sovrin_config.py
fi
chown sovrin:sovrin /home/sovrin/.sovrin/sovrin_config.py

#--------------------------------------------------------
echo 'Cleaning Up'
rm /etc/update-motd.d/10-help-text
rm /etc/update-motd.d/97-overlayroot
apt-get update
#DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
updatedb
