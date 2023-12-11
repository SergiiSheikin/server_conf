#!/bin/bash

# Шлях до конфігураційного файлу logrotate для Asterisk
LOGROTATE_CONF="/etc/logrotate.d/asterisk"

# Створення або оновлення конфігурації logrotate
cat <<EOL > "$LOGROTATE_CONF"
/var/log/asterisk/queue_log /var/spool/mail/asterisk /var/log/asterisk/freepbx_security.log /var/log/asterisk/freepbx.log /var/log/asterisk/messages {
    su asterisk asterisk
    daily
    missingok
    rotate 30
    notifempty
    sharedscripts
    create 0640 asterisk asterisk
}

/var/log/asterisk/full {
    su asterisk asterisk
    daily
    missingok
    rotate 7
    notifempty
    sharedscripts
    create 0640 asterisk asterisk
    postrotate
        /usr/sbin/asterisk -rx 'logger reload' > /dev/null 2>&1 || true
    endscript
}
EOL

# Вивід повідомлення про успішне налаштування
echo "Logrotate для Asterisk налаштовано успішно."
