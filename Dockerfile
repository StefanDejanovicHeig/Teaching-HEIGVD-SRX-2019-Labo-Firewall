FROM ubuntu

RUN apt-get update && apt-get install net-tools iptables iputils-ping iproute2 whois wget netcat nginx ssh vim -y
