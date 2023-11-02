#!/bin/bash

# Встановити iptables
yum install -y iptables iptables-services
systemctl start iptables
systemctl enable iptables

iptables -F &&
iptables -A INPUT -i lo -j ACCEPT &&
iptables -A INPUT -p tcp --dport 22 -j ACCEPT &&
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT &&
iptables -P INPUT DROP &&
iptables -P FORWARD DROP &&
iptables -P OUTPUT ACCEPT &&
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT &&
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT &&
iptables -A INPUT -p udp -m udp --dport 5060 -j ACCEPT &&
iptables -A INPUT -p udp -m udp --dport 69 -j ACCEPT &&
iptables -A INPUT -p udp -m udp --dport 10000:20000 -j ACCEPT &&
service iptables save

echo "Налаштування iptables завершено!"

exit 0