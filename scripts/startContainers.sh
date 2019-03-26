#!/bin/bash

dockerDMZ="docker exec -t dmz"
dockerLAN="docker exec -t lan"

# Start Firewall, dmz and LAN
echo "Starting Firewall, DMZ and LAN ..."
docker start firewall dmz lan

# Set default route for LAN
echo "Set default LAN route"
$dockerLAN ip route del default 
$dockerLAN ip route add default via 192.168.100.2

# Set default root for DMZ
echo "Set default DMZ route"
$dockerDMZ ip route del default
$dockerDMZ ip route add default via 192.168.200.2

gnome-terminal -- "./openfirewall.sh"
gnome-terminal -- "./opendmz.sh"
gnome-terminal -- "./openlan.sh"
