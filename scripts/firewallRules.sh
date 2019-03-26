#!/bin/bash
docker="docker exec -t firewall"

#clean iptables 
echo "0.0 flush iptable rules"
$docker iptables -F
$docker iptables -X


# Drop all request by default
echo "0.1 Set default policy to 'DROP'"
$docker iptables -P INPUT DROP
$docker iptables -P OUTPUT DROP
$docker iptables -P FORWARD DROP


# return traffic 
echo "0.2 Allows return traffic : RELATED, ESTABLISHED"
$docker iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$docker iptables -A FORWARD -m conntrack --ctstate INVALID -j DROP


#---------
# 1. PING
#--------
echo "1. Allows pings echo-request & echo-reply"
# LAN --> WAN
$docker iptables -A FORWARD -s 192.168.100.0/24 -i eth2 -p icmp --icmp-type 8 -j ACCEPT
$docker iptables -A FORWARD -d 192.168.100.0/24 -i eth0 -p icmp --icmp-type 0 -j ACCEPT

# DMZ --> LAN
$docker iptables -A FORWARD -s 192.168.200.0/24 -d 192.168.100.0/24 -p icmp --icmp-type 8 -j ACCEPT
$docker iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.200.0/24 -p icmp --icmp-type 0 -j ACCEPT

# LAN --> DMZ
$docker iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.200.0/24 -p icmp --icmp-type 8 -j ACCEPT
$docker iptables -A FORWARD -s 192.168.200.0/24 -d 192.168.100.0/24 -p icmp --icmp-type 0 -j ACCEPT

#----------
# 2. DNS
#----------
echo "2. Allows DNS lookups (tcp, udp port 53)" 
# LAN --> WAN
$docker iptables -A FORWARD -s 192.168.100.0/24 -i eth2 -p udp --dport 53 -j ACCEPT
$docker iptables -A FORWARD -s 192.168.100.0/24 -i eth2 -p tcp --dport 53 -j ACCEPT


