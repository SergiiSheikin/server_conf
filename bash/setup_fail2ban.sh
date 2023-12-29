#!/bin/bash

# Встановлення epel-release та fail2ban
sudo yum -y install epel-release
sudo yum -y install fail2ban

# Копіювання конфігурації fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Редагування jail.local 
sudo sed -i '/^#ignoreip = 127.0.0.1\/8 ::1/s/^#//' /etc/fail2ban/jail.local
services=("asterisk" "sshd" "apache-auth" "apache-badbots" "apache-botsearch" "apache-fakegooglebot" "apache-modsecurity" "apache-nohome" "apache-noscript" "apache-overflows" "apache-shellshock" "mysqld-auth" "php-url-fopen")
for service in "${services[@]}"
do
    sudo sed -i "/^\[$service\]$/a enabled = yes" /etc/fail2ban/jail.local
done

# Запис параметрів у файл
echo "messages => debug,error,notice,verbose,warning" >> /etc/asterisk/logger_logfiles_custom.conf

# Додавання налаштувань для FreePBX у jail.local
sudo bash -c 'cat <<EOL >> /etc/fail2ban/jail.local
[freepbx]
enabled = yes
port = http
logpath = /var/log/asterisk/freepbx_security.log
EOL'

# Створення файлу /etc/fail2ban/filter.d/freepbx.conf та його редагування
sudo bash -c 'cat <<EOL > /etc/fail2ban/filter.d/freepbx.conf
[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
#before = common.conf


[Definition]

#_daemon = freepbx

# Option:  failregex
# Notes.:  regex to match the password failures messages in the logfile. The
#          host must be matched by a group named "host". The tag "<HOST>" can
#          be used for standard IP/hostname matching and is only an alias for
#          (?:::f{4,6}:)?(?P<host>[\w\-.^_]+)
# Values:  TEXT
#
failregex = Authentication failure for .* from <HOST>

# Option:  ignoreregex
# Notes.:  regex to ignore. If this regex matches, the line is ignored.
# Values:  TEXT
#
ignoreregex =
EOL'

# Перезапуск служби fail2ban
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
