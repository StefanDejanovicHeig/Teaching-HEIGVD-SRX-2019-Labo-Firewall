#!/bin/bash
docker="docker exec -t firewall"
$docker iptables -P INPUT ACCEPT
$docker iptables -P OUTPUT ACCEPT
$docker iptables -P FORWARD ACCEPT
echo "0.0 flush iptable rules"
$docker iptables -F
$docker iptables -X
