# Setup php5-fpm

function gsn_setup_php()
{
  gsn_lib_echo "Setting up PHP5, please wait..."

  # Custom php5 log directory
  if [ ! -d /var/log/php5/ ]; then
    mkdir -p /var/log/php5/ || gsn_lib_error "Unable to create /var/log/PHP5/, exit status = " $?
  fi

  # dont run again if it has already been run
  grep "GSN" /etc/php5/fpm/php.ini &> /dev/null
  if [ $? -ne 0 ]; then
    local gsn_time_zone=$(cat /etc/timezone | head -n1 | sed "s'/'\\\/'")

    # make backup of existing file to cli before modifying global file in fpm
    # find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

    # Adjust php.ini
    sed -i "s/\[PHP\]/[PHP]\n; GSN/" /etc/php5/fpm/php.ini
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
    sed -i "s/expose_php.*/expose_php = Off/" /etc/php5/fpm/php.ini
    sed -i "s/post_max_size.*/post_max_size = 100M/" /etc/php5/fpm/php.ini
    sed -i "s/upload_max_filesize.*/upload_max_filesize = 100M/" /etc/php5/fpm/php.ini
    sed -i "s/max_execution_time.*/max_execution_time = 300/" /etc/php5/fpm/php.ini
    sed -i "s/;date.timezone.*/date.timezone = $gsn_time_zone/" /etc/php5/fpm/php.ini

    # Change php5-fpm error log location
    sed -i "s'error_log.*'error_log = /var/log/php5/fpm.log'" /etc/php5/fpm/php-fpm.conf

    # Enable php status and ping
    sed -i "s/;ping.path/ping.path/" /etc/php5/fpm/pool.d/www.conf
    sed -i "s/;pm.status_path/pm.status_path/" /etc/php5/fpm/pool.d/www.conf
    sed -i "s/;catch_workers_output/catch_workers_output/" /etc/php5/fpm/pool.d/www.conf

    # Adjust php5-fpm pool
    sed -i "s/;pm.max_requests = 500/pm.max_requests = 200/" /etc/php5/fpm/pool.d/www.conf
    #sed -i "s/pm.max_children = 5/pm.max_children = 40/" /etc/php5/fpm/pool.d/www.conf
    #sed -i "s/pm.start_servers = 2/pm.start_servers = 4/" /etc/php5/fpm/pool.d/www.conf
    #sed -i "s/pm.min_spare_servers = 1/pm.min_spare_servers = 4/" /etc/php5/fpm/pool.d/www.conf
    #sed -i "s/pm.max_spare_servers = 3/pm.max_spare_servers = 12/" /etc/php5/fpm/pool.d/www.conf
    sed -i "s/;request_terminate_timeout.*/request_terminate_timeout = 300/" /etc/php5/fpm/pool.d/www.conf

    # Adjust php5-fpm listen sock is faster than tcp
    #sed -i "s'listen = /var/run/php5-fpm.sock'listen = 127.0.0.1:9000'" /etc/php5/fpm/pool.d/www.conf \
    #|| gsn_lib_error "Unable to change php5-fpm listen socket, exit status = " $?
    
    # duplicating sock and load balance them instead of increasing max-children (commented out above)
    # sock tends to fail, having multiple sock decrease failure rate
    cp /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www2.conf
    cp /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www3.conf
    sed -i "s'listen = /var/run/php5-fpm.sock'listen = /var/run/php5-fpm.sock2'" /etc/php5/fpm/pool.d/www2.conf
    sed -i "s'listen = /var/run/php5-fpm.sock'listen = /var/run/php5-fpm.sock3'" /etc/php5/fpm/pool.d/www3.conf
    
    

    #gsn_lib_echo "Downloading GeoIP Database, please wait..."
    #mkdir -p /usr/share/GeoIP
    #wget -qO  /usr/share/GeoIP/GeoLiteCity.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
    #gunzip /usr/share/GeoIP/GeoLiteCity.dat.gz
    #mv /usr/share/GeoIP/GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat

    # Setup Zend OpCache optimized for 4gig of ram wordpress worker (T2.Medium)
    if [ -f /etc/php5/mods-available/opcache.ini ]; then
      grep memory_consumption /etc/php5/mods-available/opcache.ini &> /dev/null
      if [ $? -ne 0 ]; then
        sed -i "s/zend_extension=opcache.so/zend_extension=opcache.so\nopcache.memory_consumption=128\nopcache.max_accelerated_files=4000\nopcache.revalidate_freq=60/" /etc/php5/mods-available/opcache.ini \
        || gsn_lib_error "Unable to change opcache.memory_consumption, exit status = " $?
      fi
    fi

  fi
}
