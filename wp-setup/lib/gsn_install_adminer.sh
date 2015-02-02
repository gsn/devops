# Install Adminer

function gsn_install_adminer()
{
  if [ ! -d /mnt/sharefs/admin/htdocs/db/adminer ]; then

    # Setup Adminer
    mkdir -p /mnt/sharefs/admin/htdocs/db/adminer/ \
    || gsn_lib_error "Unable to create Adminer directory: /mnt/sharefs/admin/htdocs/db/adminer/, exit status = " $?

    # Download Adminer
    gsn_lib_echo "Setup adminer"
    cp $CWD/config/adminer-4.1.0-mysql-en.php /mnt/sharefs/admin/htdocs/db/adminer/index.php

  fi
}
