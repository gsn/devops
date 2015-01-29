#!/bin/bash

echo "************ create a directory for the shared data"
mkdir -p /mnt/sharefs

echo "Enter the IP or domain of the admin box where the shared volume is:"
read server

echo "************ mount the shared filesystem"
mount "$server":/mnt/sharefs /mnt/sharefs 

echo "************ set automatic mounting in case of reboot"
echo 'echo "admin.prodwp.gsn2.com:/mnt/sharefs /mnt/sharefs nfs4 soft,intr,rsize=8192,wsize=8192,nosuid" >> /etc/fstab' | sudo -s

echo "************ restart nginx"
service nginx restart
