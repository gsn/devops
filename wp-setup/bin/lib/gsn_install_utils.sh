# Install admin utilities

function gsn_install_utils()
{
	dpkg -l | grep php5-fpm
	if [ $? -eq 0 ]; then
		# Setup phpMemcachedAdmin
		if [ ! -d /mnt/sharefs/admin/cache/memcache ];then
			# Create memcache directory
			mkdir -p /mnt/sharefs/admin/cache/memcache \
			|| ee_lib_error "Unable to create /mnt/sharefs/admin/cache/memcache directory, exit status = " $?

			# Download phpMemcachedAdmin
			ee_lib_echo "Installing phpMemcachedAdmin, please wait..."
			wget --no-check-certificate -cqO /mnt/sharefs/admin/cache/memcache/memcache.tar.gz http://phpmemcacheadmin.googlecode.com/files/phpMemcachedAdmin-1.2.2-r262.tar.gz \
			|| ee_lib_error "Unable to download phpMemcachedAdmin, exit status = " $?

			# Extract phpMemcachedAdmin
			tar -zxf /mnt/sharefs/admin/cache/memcache/memcache.tar.gz -C /mnt/sharefs/admin/cache/memcache

			# Remove unwanted file
			rm -f /mnt/sharefs/admin/cache/memcache/memcache.tar.gz
		fi

		# PHP5-FPM status page
		if [ ! -d /mnt/sharefs/admin/fpm/status/ ]; then
			mkdir -p /mnt/sharefs/admin/fpm/status/ \
			|| ee_lib_error "Unable to create /mnt/sharefs/admin/fpm/status/ directory, exit status = " $?
			touch /mnt/sharefs/admin/fpm/status/{php,debug}
		fi

		# phpinfo()
		echo -e "<?php \n\t phpinfo(); \n?>" &>> /mnt/sharefs/admin/php/info.php
	fi
}
