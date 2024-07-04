#!/bin/sh

mv /etc/resolv.conf /etc/resolv.conf.bak
touch /etc/resolv.conf
chmod 777 /etc/resolv.conf
echo 'nameserver 10.202.10.202' >> /etc/resolv.conf
echo 'nameserver 10.202.10.102' >> /etc/resolv.conf

