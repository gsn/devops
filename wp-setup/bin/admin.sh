#!/bin/bash

# execute in home directory
mkdir ~/gsn-git

echo "************ nfs requirements"
apt-get install nfs-kernel-server

echo "************ create a file system and folder on the elastic block store volume (disk)"
mkfs -t ext4 /dev/xvdf

echo "************ create a mount point"
mkdir /mnt/sharefs

echo "************ mount the attached ebs to /wordpress"
mount /dev/xvdf /mnt/sharefs

mkdir /mnt/sharefs/wordpress
mkdir /mnt/sharefs/wordpress/htdocs
mkdir /mnt/sharefs/admin
mkdir /mnt/sharefs/admin/htdocs

echo "************ give permission to access the drive to the worker(s)"
echo "\n/mnt/sharefs 10.0.0.0/16(rw,sync,no_subtree_check)" >> /etc/exports

service nfs-kernel-server restart

echo "************ clone the gsn wp repo"
git clone --recursive https://github.com/gsn/wp-multisite-skeleton.git ~/gsn-git/wp-multisite-skeleton

echo "************ move the wordpress files"
mv ~/gsn-git/wp-multisite-skeleton/wp/* /mnt/sharefs/wordpress/htdocs
mv ~/gsn-git/wp-multisite-skeleton/content/themes/* /mnt/sharefs/wordpress/htdocs/wp-content/themes
mv ~/gsn-git/wp-multisite-skeleton/content/plugins/* /mnt/sharefs/wordpress/htdocs/wp-content/plugins

echo "************ change the ownership of the wordpress folder"
chown -R www-data:www-data /mnt/sharefs

echo "************ folders to 755 and all files to 644"
# set all folders to 755 and all files to 644
find /mnt/sharefs/ -type d -exec chmod 755 {} \;
find /mnt/sharefs/ -type f -exec chmod 644 {} \;

sed -i -e "s/pm.max_children\s*=\s*40/pm.max_children = 80/g" /etc/php5/fpm/pool.d/www.conf
sed -i -e "s/pm.start_servers\s*=\s*4/pm.start_servers = 8/g" /etc/php5/fpm/pool.d/www.conf
sed -i -e "s/pm.min_spare_servers\s*=\s*4/pm.min_spare_servers = 8/g" /etc/php5/fpm/pool.d/www.conf
sed -i -e "s/pm.max_spare_servers\s*=\s*20/pm.max_spare_servers = 32/g" /etc/php5/fpm/pool.d/www.conf
sed -i -e "s/pm.max_requests\s*=\s*200/pm.max_requests = 800/g" /etc/php5/fpm/pool.d/www.conf

echo "************ restart nginx"
service nginx restart