#!/bin/sh

# Drop everything and clear rules
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -F

# Drop input and forward requests by default
iptables -P OUTPUT ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP

iptables -A INPUT -i eth0 -s 127.0.0.1 -j DROP
iptables -A FORWARD -i eth0 -s 127.0.0.1 -j DROP
iptables -A INPUT -i eth0 -d 127.0.0.1 -j DROP
iptables -A FORWARD -i eth0 -d 127.0.0.1 -j DROP

# Loopback
iptables -A INPUT -s 127.0.0.1 -j ACCEPT
iptables -A INPUT -d 127.0.0.1 -j ACCEPT

# Ping over external
iptables -A INPUT -i eth0 -p icmp --icmp-type echo-request -j ACCEPT

# Accept all via vpn
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT

# vpn related rules
iptables -A OUTPUT -m state --state NEW -o eth0 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state NEW -o eth0 -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
