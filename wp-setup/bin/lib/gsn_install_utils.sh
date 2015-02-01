# Install admin utilities

function gsn_install_utils()
{
  dpkg -l | grep php5-fpm
  if [ $? -eq 0 ]; then
    # Setup phpMemcachedAdmin
    if [ ! -d /mnt/sharefs/admin/htdocs/cache/memcache ];then
      # Create memcache directory
      mkdir -p /mnt/sharefs/admin/htdocs/cache/memcache \
      || gsn_lib_error "Unable to create /mnt/sharefs/admin/cache/memcache directory, exit status = " $?

      # Download phpMemcachedAdmin
      gsn_lib_echo "Installing phpMemcachedAdmin, please wait..."
      wget --no-check-certificate -cqO /mnt/sharefs/admin/htdocs/cache/memcache/memcache.tar.gz http://phpmemcacheadmin.googlecode.com/files/phpMemcachedAdmin-1.2.2-r262.tar.gz \
      || gsn_lib_error "Unable to download phpMemcachedAdmin, exit status = " $?

      # Extract phpMemcachedAdmin
      tar -zxf /mnt/sharefs/admin/htdocs/cache/memcache/memcache.tar.gz -C /mnt/sharefs/admin/cache/memcache

      # Remove unwanted file
      rm -f /mnt/sharefs/admin/htdocs/cache/memcache/memcache.tar.gz
    fi

    # PHP5-FPM status page
    if [ ! -d /mnt/sharefs/admin/htdocs/fpm/status/ ]; then
      mkdir -p /mnt/sharefs/admin/htdocs/fpm/status/ \
      || gsn_lib_error "Unable to create /mnt/sharefs/admin/fpm/status/ directory, exit status = " $?
      touch /mnt/sharefs/admin/htdocs/fpm/status/{php,debug}
    fi

    # phpinfo()
    printf "<?php \n\t phpinfo(); \n?>" > /mnt/sharefs/admin/htdocs/info.php
  fi
}
