#!/bin/bash
source .env

# Отключити SELinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

# Замінити BOOTPROTO="dhcp" на BOOTPROTO="none" у файлі ifcfg-enp0s3
sed -i 's/BOOTPROTO="dhcp"/BOOTPROTO="none"/' /etc/sysconfig/network-scripts/ifcfg-enp0s3

# Додати параметри IPADDR, PREFIX і GATEWAY
echo "IPADDR=$IPADDR" >> /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo "PREFIX=$PREFIX" >> /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo "GATEWAY=$GATEWAY" >> /etc/sysconfig/network-scripts/ifcfg-enp0s3

# Вимкнути firewalld
systemctl stop firewalld
systemctl disable firewalld

systemctl stop NetworkManager
systemctl disable NetworkManager	

# Обновити
yum -y update
yum -y install epel-release
yum -y install wget mc vim gcc gcc-c++ libedit-devel sqlite-devel jansson-devel libxml2-devel libuuid-devel bzip2 patch kernel-devel-`uname -r` kernel-headers-`uname -r` newt-devel	

# Install Asterisk
cd /usr/src/
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
tar xvfz asterisk-18-current.tar.gz
rm -f asterisk-18-current.tar.gz
cd /usr/src/asterisk-18*/
contrib/scripts/install_prereq install
./configure --with-jansson-bundled --libdir=/usr/lib64 
make menuselect	
make
make install
# якщо make samples не робити то небуде конфігураційних файлів
make samples
make config
ldconfig

groupadd asterisk 
useradd -r -d /var/lib/asterisk -g asterisk asterisk 
usermod -aG audio,dialout asterisk 
chown -R asterisk.asterisk /etc/asterisk 
chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
chown -R asterisk.asterisk /usr/lib64/asterisk
chmod -R 755 /var/{lib,log,run,spool}/asterisk /usr/lib64/asterisk /etc/asterisk
	
# Розкоментувати AST_USER і AST_GROUP у /etc/sysconfig/asterisk
sed -i 's/#AST_USER="asterisk"/AST_USER="asterisk"/' /etc/sysconfig/asterisk
sed -i 's/#AST_GROUP="asterisk"/AST_GROUP="asterisk"/' /etc/sysconfig/asterisk

# Розкоментувати та встановити значення runuser та rungroup у /etc/asterisk/asterisk.conf
sed -i 's/;runuser = asterisk/runuser = asterisk/' /etc/asterisk/asterisk.conf
sed -i 's/;rungroup = asterisk/rungroup = asterisk/' /etc/asterisk/asterisk.conf

systemctl enable asterisk
systemctl start asterisk

# Створюємо користувача із заданим ім'ям та паролем
useradd -m -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

# Додаємо налаштування SSH до конфігураційного файлу
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "AllowUsers $USERNAME" >> /etc/ssh/sshd_config

echo "Налаштування завершено."

exit 0