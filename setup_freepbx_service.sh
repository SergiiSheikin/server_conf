#!/bin/bash

# Створення файлу служби
sudo bash -c 'cat <<EOL > /etc/systemd/system/freepbx.service
[Unit]
Description=FreePBX VoIP Server
After=mariadb.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/fwconsole start
ExecStop=/usr/sbin/fwconsole stop

[Install]
WantedBy=multi-user.target
EOL'

# Перезавантаження конфігурації systemd
sudo systemctl daemon-reload

# Запуск служби FreePBX
sudo systemctl start freepbx.service

# Налаштування автозапуску служби
sudo systemctl enable freepbx.service
