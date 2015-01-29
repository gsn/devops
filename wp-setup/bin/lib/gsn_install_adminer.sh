# Install Adminer

function gsn_install_adminer()
{
	if [ ! -d /mnt/sharefs/admin/db/adminer ]; then
		
		# Setup Adminer
		mkdir -p /mnt/sharefs/admin/db/adminer/ \
		|| ee_lib_error "Unable to create Adminer directory: /mnt/sharefs/admin/db/adminer/, exit status = " $?

		# Download Adminer
		ee_lib_echo "Downloading Adminer, please wait..."
		wget --no-check-certificate -cqO /var/www/admin/db/adminer/index.php http://downloads.sourceforge.net/adminer/adminer-${GSN_ADMINER_VERSION}.php \
		|| ee_lib_error "Unable to download Adminer, exit status = " $?

	fi
}
