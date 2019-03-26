#!/bin/bash
docker="sudo docker exec -t firewall"

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
# 2. PING
#--------
echo "2. Allows pings echo-request & echo-reply"
#$docker iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
#$docker iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT

# LAN --> WAN
$docker iptables -A FORWARD -s 192.168.100.0/24 -i eth0 -p icmp --icmp-type 8 -j ACCEPT
$docker iptables -A FORWARD -d 192.168.100.0/24 -p icmp --icmp-type 0 -j ACCEPT
#$docker iptables -A FORWARD -d 192.168.100.0/24 -i eth2 -p icmp --icmp-type 0 -j ACCEPT

# DMZ --> LAN
$docker iptables -A FORWARD -s 192.168.200.0/24 -d 192.168.100.0/24 -p icmp --icmp-type 8 -j ACCEPT
$docker iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.200.0/24 -p icmp --icmp-type 0 -j ACCEPT

# LAN --> DMZ
$docker iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.200.0/24 -p icmp --icmp-type 8 -j ACCEPT
$docker iptables -A FORWARD -s 192.168.200.0/24 -d 192.168.100.0/24 -p icmp --icmp-type 0 -j ACCEPT

echo "2. done"



: '
DEBUG
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

echo "0.1 Set default policy to 'DROP'"
$docker iptables -P INPUT ACCEPT
$docker iptables -P OUTPUT ACCEPT
$docker iptables -P FORWARD ACCEPT



#----------
# 1. DNS
#----------
echo "1. Allowing DNS lookups (tcp, udp port 53)" 
# UDP
$docker iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
$docker iptables -A INPUT -p udp --sport 53 -j ACCEPT
# LAN --> * (DMZ,LAN,...)
$docker iptables -A FORWARD -s 192.168.100.0/24 -p udp --dport 53 -j ACCEPT
$docker iptables -A FORWARD -d 192.168.100.0/24 -p udp --sport 53 -j ACCEPT

# TCP
$docker iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
$docker iptables -A INPUT -p tcp --sport 53 -j ACCEPT
# LAN --> * (DMZ,LAN,...)
$docker iptables -A FORWARD -s 192.168.100.0/24 -p tcp --dport 53 -j ACCEPT
$docker iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 53 -j ACCEPT




#---------
# 3. HTTP
#--------
echo "3. Allows HTTP Connection"


# LAN --> * (DMZ,LAN,...)
$docker iptables -A FORWARD -s 192.168.100.0/24 -p tcp --dport 80 -j ACCEPT
$docker iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 80 -j ACCEPT



#---------
# 4. HTTPS
#--------
echo "4. Allows HTTPS secure Connection"


# LAN --> * (DMZ,LAN,...)
$docker iptables -A FORWARD -s 192.168.100.0/24 -p tcp --dport 443 -j ACCEPT
$docker iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 443 -j ACCEPT


#---------
# 5. HTTP DMZ
#--------
echo "5. Allows to reach DMZ on 80 8080 from LAN and WAN"

# (LAN, WAN, ...) * --> DMZ.3
$docker iptables -A FORWARD -s 192.168.200.3 -p tcp --dport 80 -j ACCEPT
$docker iptables -A FORWARD -d 192.168.200.3 -p tcp --sport 80 -j ACCEPT
$docker iptables -A FORWARD -s 192.168.200.3 -p tcp --dport 8080 -j ACCEPT
$docker iptables -A FORWARD -d 192.168.200.3 -p tcp --sport 8080 -j ACCEPT

#---------
# 6. SSH DMZ
#--------
echo "6. Allows to admin DMZ with SSH from LAN"

# LAN --> DMZ.3
$docker iptables -A FORWARD -s 192.168.100.3 -d 192.168.200.3 -p tcp --dport 22 -j ACCEPT
$docker iptables -A FORWARD -s 192.168.200.3 -d 192.168.100.3 -p tcp --dport 22 -j ACCEPT

#---------
# 6. SSH FIREWALL
#--------
echo "7. Allows to admin FIREWALL with SSH from LAN"

# LAN --> FIREWALL
$docker iptables -A INPUT -s 192.168.100.3 -p tcp --dport 22  -j ACCEPT
$docker iptables -A OUTPUT -d 192.168.100.3 -p tcp  --dport 22 -j ACCEPT
'