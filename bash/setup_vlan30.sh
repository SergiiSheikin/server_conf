#!/bin/bash
source .env
sudo yum -y remove NetworkManager NetworkManager-libnm NetworkManager-team NetworkManager-tui NetworkManager-wifi
# Встановлення модуля 8021q
sudo modprobe 8021q

# Додавання модуля до /etc/modules
sudo su -c 'echo "8021q" >> /etc/modules'

# Створення файлу /etc/sysconfig/network-scripts/ifcfg-enp0s3.30
sudo bash -c 'cat <<EOL > /etc/sysconfig/network-scripts/ifcfg-enp0s3.30
DEVICE=enp0s3.30
BOOTPROTO=none
ONBOOT=yes
IPADDR='$IPADDRVLAN'
NETMASK='$NETMASKVLAN'
NETWORK='$NETWORKVLAN'
VLAN=yes
EOL'

# Створення файлу /etc/sysconfig/network-scripts/rule-enp0s3.30
sudo bash -c 'echo "from '$RULEVLAN' tab 1 priority 500" > /etc/sysconfig/network-scripts/rule-enp0s3.30'

# Створення файлу /etc/sysconfig/network-scripts/route-enp0s3.30
sudo bash -c 'echo "default via '$ROUTVLAN' dev enp0s3.30 table 1" > /etc/sysconfig/network-scripts/route-enp0s3.30'

# Створення файлу /etc/sysctl.d/90-override.conf
sudo bash -c 'cat <<EOL > /etc/sysctl.d/90-override.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.arp_filter=0
net.ipv4.conf.all.rp_filter=2
EOL'

sudo sysctl -p /etc/sysctl.d/90-override.conf
sudo reboot
