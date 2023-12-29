#!/bin/bash
# Завантаження змін з .env файлу
if [ -f .env ]; then
    source .env
else
    echo "Файл .env не знайдено. Заповніть його та спробуйте знову."
    exit 1
fi

# Відключити SELinux
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

yum -y update
yum -y groupinstall core base "Development Tools"

yum -y install mc lynx mariadb-server mariadb php php-mysql php-mbstring tftp-server \
  httpd ncurses-devel sendmail sendmail-cf sox newt-devel libxml2-devel libtiff-devel \
  audiofile-devel gtk2-devel subversion kernel-devel git php-process crontabs cronie \
  cronie-anacron wget vim php-xml uuid-devel sqlite-devel net-tools gnutls-devel php-pear unixODBC mysql-connector-odbc

pear install Console_Getopt

systemctl enable mariadb.service
systemctl start mariadb
mysql_secure_installation

systemctl enable httpd.service
systemctl start httpd.service

adduser asterisk -m -c "Asterisk User"

cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-1-current.tar.gz
wget https://downloads.asterisk.org/pub/telephony/asterisk/old-releases/asterisk-13.38.3.tar.gz
wget -O jansson.tar.gz https://github.com/akheron/jansson/archive/v2.7.tar.gz
wget https://github.com/pjsip/pjproject/archive/refs/tags/2.4.tar.gz

cd /usr/src
tar xvfz dahdi-linux-complete-current.tar.gz
tar xvfz libpri-1-current.tar.gz
rm -f dahdi-linux-complete-current.tar.gz libpri-1-current.tar.gz
cd dahdi-linux-complete-*
make all
make install
make config
cd /usr/src/libpri-*
make
make install

cd /usr/src
tar -xjvf pjproject-2.4.tar.bz2
rm -f pjproject-2.4.tar.bz2
cd pjproject-2.4
CFLAGS='-DPJ_HAS_IPV6=1' ./configure --prefix=/usr --enable-shared --disable-sound\
  --disable-resample --disable-video --disable-opencore-amr --libdir=/usr/lib64
make dep
make
make install

cd /usr/src
tar vxfz jansson.tar.gz
rm -f jansson.tar.gz
cd jansson-*
autoreconf -i
./configure --libdir=/usr/lib64
make
make install

cd /usr/src
tar xvfz asterisk-13.38.3.tar.gz
rm -f asterisk-13.38.3.tar.gz
cd asterisk-*
contrib/scripts/install_prereq install
./configure --libdir=/usr/lib64
contrib/scripts/get_mp3_source.sh
make menuselect
make
make install
make config
ldconfig
chkconfig asterisk off

chown asterisk. /var/run/asterisk
chmod 755 /var/run/asterisk
chown -R asterisk. /etc/asterisk
chmod -R 755 /etc/asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chmod -R 755 /var/{lib,log,spool}/asterisk
chown -R asterisk. /usr/lib64/asterisk
chmod -R 755 /usr/lib64/asterisk
chown -R asterisk. /var/www/
chmod -R 755 /var/www/

sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
systemctl restart httpd.service

cd /usr/src
wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-13.0-latest.tgz
tar xfz freepbx-13.0-latest.tgz
rm -f freepbx-13.0-latest.tgz
cd freepbx
./start_asterisk start
./install -n

# Додавання користувача astuser та установка паролю
useradd -m -s /bin/bash astuser
echo "$USERNAME:$PASSWORD" | chpasswd

# Заборона входу по SSH як root
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

echo "Інсталювання завершено."

exit 0