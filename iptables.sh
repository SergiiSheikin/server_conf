#!/bin/bash

# Встановити iptables
yum install -y iptables iptables-services
systemctl start iptables
systemctl enable iptables

iptables -F &&
iptables -A INPUT -i lo -j ACCEPT && 
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT && 
iptables -A INPUT -s 10.33.85.0/24 -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT &&
iptables -A INPUT -s 10.33.85.0/24 -p icmp -m icmp --icmp-type 8 -j ACCEPT &&
iptables -A INPUT -s 10.33.85.0/24 -p tcp -m tcp --dport 80 -j ACCEPT &&
iptables -A INPUT -s 10.33.85.0/24 -p tcp -m tcp --dport 8033 -j ACCEPT &&
iptables -A INPUT -s 10.33.85.0/24 -p tcp -m tcp --dport 8080 -j ACCEPT &&
iptables -A INPUT -s 10.33.85.0/24 -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT &&
iptables -A INPUT -s 10.33.84.5/24 -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT &&
iptables -A INPUT -s 10.33.84.5/24 -p icmp -m icmp --icmp-type 8 -j ACCEPT &&
iptables -A INPUT -s 10.33.84.5/24 -p tcp -m tcp --dport 80 -j ACCEPT &&
iptables -A INPUT -s 10.33.84.5/24 -p tcp -m tcp --dport 8033 -j ACCEPT &&
iptables -A INPUT -s 10.33.84.5/24 -p tcp -m tcp --dport 8080 -j ACCEPT &&
iptables -A INPUT -s 10.33.84.5/24 -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT &&
iptables -A INPUT -s 10.0.0.0/24 -p udp -m udp --dport 5060 -j ACCEPT &&
iptables -A INPUT -s 10.0.0.0/24 -p udp -m udp --dport 10000:50000 -j ACCEPT &&
iptables -A INPUT -s 10.0.0.0/24 -p udp -m udp --dport 69 -j ACCEPT &&
iptables -P INPUT DROP &&
iptables -P FORWARD DROP && 
iptables -P OUTPUT ACCEPT && 
service iptables save && 
iptables -nvL


exit 0