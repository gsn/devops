# Setup nginx

function ee_mod_setup_nginx()
{
	local ee_whitelist_ip_address
	local ee_random=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n1)
	
	ee_lib_echo "Setting up NGINX, please wait..."

	grep "GSN" /etc/nginx/nginx.conf &>> /dev/null
	if [ $? -ne 0 ]; then

		# Adjust nginx worker_processes and worker_rlimit_nofile value
		sed -i "s/worker_processes.*/worker_processes auto;/" /etc/nginx/nginx.conf
		sed -i "/worker_processes/a \worker_rlimit_nofile 100000;" /etc/nginx/nginx.conf

		# Adjust nginx worker_connections and multi_accept
		sed -i "s/worker_connections.*/worker_connections 4096;/" /etc/nginx/nginx.conf
		sed -i "s/# multi_accept/multi_accept/" /etc/nginx/nginx.conf

		# Disable nginx version
		# Set custom header
		# SSL Settings
		sed -i "s/http {/http {\n\t##\n\t# GSN Settings\n\t##\n\n\tserver_tokens off;\n\treset_timedout_connection on;\n\tadd_header X-Powered-By \"GroceryShoppingNetwork 1.0\";\n\tadd_header rt-Fastcgi-Cache \$upstream_cache_status;\n\n\t# Limit Request\n\tlimit_req_status 403;\n\tlimit_req_zone \$binary_remote_addr zone=one:10m rate=1r\/s;\n\n\t# Proxy Settings\n\t# set_real_ip_from\tproxy-server-ip;\n\t# real_ip_header\tX-Forwarded-For;\n\n\tfastcgi_read_timeout 300;\n\tclient_max_body_size 100m;\n\n\t# SSL Settings\n\tssl_session_cache shared:SSL:20m;\n\tssl_session_timeout 10m;\n\tssl_prefer_server_ciphers on;\n\tssl_ciphers HIGH:\!aNULL:\!MD5:\!kEDH;\n\t# Fix POODLE attack\n\tssl_protocols TLSv1 TLSv1.1 TLSv1.2;\n\n/" /etc/nginx/nginx.conf

		# Adjust nginx keepalive_timeout
		sed -i "s/keepalive_timeout.*/keepalive_timeout 30;/" /etc/nginx/nginx.conf

		# Adjust nginx log format
		sed -i "s/error_log.*/error_log \/var\/log\/nginx\/error.log;\n\n\tlog_format rt_cache '\$remote_addr \$upstream_response_time \$upstream_cache_status [\$time_local] '\n\t\t'\$http_host \"\$request\" \$status \$body_bytes_sent '\n\t\t'\"\$http_referer\" \"\$http_user_agent\"';/" /etc/nginx/nginx.conf

		# Enable Gun-zip
		sed -i "s/# gzip/gzip/" /etc/nginx/nginx.conf
	fi

	# Update GSN version
	# Launchpad PPA already have above settings
	# On Ubuntu above block never executed
	sed -i "s/X-Powered-By.*/X-Powered-By \"GroceryShoppingNetwork 1.0\";/" /etc/nginx/nginx.conf 

	# Create directory if not exist
	if [ ! -d /etc/nginx/conf.d ]; then
		mkdir /etc/nginx/conf.d || ee_lib_error "Unable to create /etc/nginx/conf.d, exit status = " $?
	fi

	if [ ! -d /etc/nginx/common ]; then
		mkdir /etc/nginx/common || ee_lib_error "Unable to create /etc/nginx/common, exit status = " $?
	fi

	# Copy files
	cp -a ../config/nginx/conf.d ../config/nginx/common /etc/nginx

	# Setup service conf
	cp ../config/nginx/sites-available/*.conf /etc/nginx/sites-available/
  
	# Delete default link
	if [ -L /etc/nginx/sites-enabled/default ]; then
		rm -rf /etc/nginx/sites-enabled/default
	fi
  
	# Create a symbolic link for admin
	if [ ! -L /etc/nginx/sites-enabled/admin.conf ]; then
		ln -s /etc/nginx/sites-available/admin.conf /etc/nginx/sites-enabled/
	fi
  
	# Create a symbolic link for admin
	if [ ! -L /etc/nginx/sites-enabled/wordpress.conf ]; then
		ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/
	fi

	# Setup logs for admin
	if [ ! -d /var/www/admin/logs ]; then
		mkdir -p /var/www/admin/logs
		ln -s /var/log/nginx/admin.access.log /var/www/admin/logs/access.log
		ln -s /var/log/nginx/admin.error.log /var/www/admin/logs/error.log
	fi

	# Setup SSL
	# Create SSL certificate directory
	if [ ! -d /var/www/admin/cert ]; then
		mkdir /var/www/admin/cert
	fi
	
	# Generate SSL key
	ee_lib_echo "Generating SSL private key"
	openssl genrsa -out /var/www/admin/cert/admin.key 2048

	ee_lib_echo "Generating a certificate signing request (CSR)"
	openssl req -new -batch -subj /commonName=127.0.0.1/ -key /var/www/admin/cert/admin.key -out /var/www/admin/cert/admin.csr 

	ee_lib_echo "Removing pass phrase from SSL private key"
	mv /var/www/admin/cert/admin.key /var/www/admin/cert/admin.key.org
	openssl rsa -in /var/www/admin/cert/admin.key.org -out /var/www/admin/cert/admin.key

	ee_lib_echo "Generating SSL certificate"
	openssl x509 -req -days 3652 -in /var/www/admin/cert/admin.csr -signkey /var/www/admin/cert/admin.key -out /var/www/admin/cert/admin.crt
}
