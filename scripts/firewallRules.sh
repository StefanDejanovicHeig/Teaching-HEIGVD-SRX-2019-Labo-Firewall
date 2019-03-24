#!/bin/bash
docker="sudo docker exec -t firewall"

#clean iptables 
echo "flush iptable rules"
$docker iptables -F
$docker iptables -X


# Drop all request by default
echo "Set default policy to 'DROP'"
$docker iptables -P INPUT DROP
$docker iptables -P OUTPUT DROP
$docker iptables -P FORWARD DROP



#----------
# DNS
#----------


echo "Allowing DNS lookups (tcp, udp port 53)" 
# UDP
$docker iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
$docker iptables -A INPUT -p udp --sport 53 -j ACCEPT

# TCP
$docker iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
$docker iptables -A INPUT -p tcp --sport 53 -j ACCEPT


## return traffic 
echo "Allows return traffic : RELATED, ESTABLISHED"
$docker iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$docker iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

#---------
# PING
#--------
$docker iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
$docker iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT

