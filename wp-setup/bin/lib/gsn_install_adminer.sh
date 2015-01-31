# Install Adminer

function gsn_install_adminer()
{
  if [ ! -d /mnt/sharefs/admin/db/adminer ]; then

    # Setup Adminer
    mkdir -p /mnt/sharefs/admin/db/adminer/ \
    || gsn_lib_error "Unable to create Adminer directory: /mnt/sharefs/admin/db/adminer/, exit status = " $?

    # Download Adminer
    gsn_lib_echo "Setup adminer"
    cp ../config/adminer-4.1.0-mysql-en.php /var/www/admin/db/adminer/index.php

  fi
}
