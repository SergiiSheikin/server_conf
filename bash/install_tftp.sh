#!/bin/bash

# Встановлення TFTP та xinetd
sudo yum -y install tftp-server xinetd

# Очищення існуючого вмісту файлу /etc/xinetd.d/tftp
echo "" > /etc/xinetd.d/tftp 

# Налаштування TFTP в /etc/xinetd.d/tftp
sudo bash -c 'cat <<EOL > /etc/xinetd.d/tftp
service tftp
{
    socket_type            = dgram
    protocol               = udp
    wait                   = yes
    user                   = root
    server                 = /usr/sbin/in.tftpd
    server_args            = -s /tftpboot
    disable                = no
    per_source             = 11
    cps                    = 100 2
    flags                  = IPv4
}
EOL'

# Перезапуск xinetd
sudo systemctl restart xinetd

# Створення папок та установка прав доступу
sudo mkdir -p "/tftpboot/{MAC}.cfg"
sudo chmod 777 "/tftpboot/{MAC}.cfg"
