#!/bin/bash
#GSN WP Client (worker) Setup
#Version 1.0.0

echo "************ nfs requirements"
apt-get install nfs-common

echo "************ create a directory for the shared data"
mkdir -p /mnt/nfs/wordpress

echo "Enter the IP or domain of the admin box where the shared volume is:"
read server

echo "************ mount the shared filesystem"
mount "$server":/mnt/sharefs/wordpress /mnt/nfs/wordpress 

echo "************ set automatic mounting in case of reboot"
echo 'echo "admin.prodwp.gsn2.com:/mnt/sharefs/wordpress /mnt/nfs/wordpress nfs4 soft,intr,rsize=8192,wsize=8192,nosuid" >> /etc/fstab' | sudo -s

echo "************ point the document root at the nfs folder"
sed -i -e "s/\/usr\/share\/nginx\/html/\/mnt\/nfs\/wordpress/g" /etc/nginx/sites-available/default

echo "************ add index.php to the list of possibles"
sed -i -e "s/index.html index.htm/index.php/g" /etc/nginx/sites-available/default

echo "************ add php section"
sed -i -e "s/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/location ~ \\\.php$ {fastcgi_split_path_info ^(.+\\\.php)(\/.+)$;fastcgi_pass unix:\/var\/run\/php5-fpm.sock;fastcgi_index index.php;include fastcgi_params;}/g" /etc/nginx/sites-available/default

echo "************ add proxy to admin"
sed -i -e "s/#location \/RequestDenied {/location \/wp-admin {proxy_pass http:\/\/admin.prodwp.gsn2.com;}/g" /etc/nginx/sites-available/default

echo "************ restart nginx"
service nginx reload


