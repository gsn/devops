# Install admin server

function gsn_setup_admin()
{
  gsn_lib_echo "add haproxy 1.5 repository..."
  add-apt-repository ppa:vbernat/haproxy-1.5

  gsn_lib_echo "apt-get update, please wait..."
  apt-get update

  gsn_lib_echo "apt-get upgrade, please wait..."
  apt-get -y upgrade

  # execute in home directory
  if [ ! -d $GSN_GIT_HOME ]; then
    gsn_lib_echo "create gsn git directory"
    mkdir $GSN_GIT_HOME
  fi

  if [ ! -d $GSN_GIT_HOME/wp-skeleton ]; then
    gsn_lib_echo "clone the gsn wp repo"
    cd $GSN_GIT_HOME
    git clone --recursive https://github.com/gsn/wp-skeleton.git
  else
    cd $GSN_GIT_HOME/wp-skeleton
    git pull
  fi

  cd $CWD

  if [ ! -d /mnt/sharefs ]; then
    gsn_lib_echo "install nfs requirements"
    apt-get -y --force-yes install nfs-kernel-server

    gsn_lib_echo "create a mount point"
    mkdir /mnt/sharefs

    read -e -p "Enter EBS device location suggest (/dev/xvdb):" -i "" EBS_DRIVE
    if [ ! -z "$EBS_DRIVE" ]; then
      mkfs -t ext4 $EBS_DRIVE

      gsn_lib_echo "mount the attached $EBS_DRIVE to /mnt/sharefs"
      mount $EBS_DRIVE /mnt/sharefs
      printf "\n/dev/xvdb  /mnt/sharefs  ext4     noatime  0 0\n" >> /etc/fstab

      gsn_lib_echo "give permission to access the drive to the worker(s)"
      printf "\n/mnt/sharefs 10.0.0.0/16(rw,sync,no_subtree_check)\n" >> /etc/exports

      service nfs-kernel-server restart
    fi

    #sed -i -e "s/pm.max_children\s*=\s*40/pm.max_children = 80/g" /etc/php5/fpm/pool.d/www.conf
    #sed -i -e "s/pm.start_servers\s*=\s*4/pm.start_servers = 8/g" /etc/php5/fpm/pool.d/www.conf
    #sed -i -e "s/pm.min_spare_servers\s*=\s*4/pm.min_spare_servers = 8/g" /etc/php5/fpm/pool.d/www.conf
    #sed -i -e "s/pm.max_spare_servers\s*=\s*12/pm.max_spare_servers = 24/g" /etc/php5/fpm/pool.d/www.conf
    #sed -i -e "s/pm.max_requests\s*=\s*200/pm.max_requests = 800/g" /etc/php5/fpm/pool.d/www.conf

    #finally, remove admin from wp-admin - this will be haproxy to worker for security
    rm -f /etc/nginx/sites-enabled/admin.conf

    gsn_lib_echo "Installing HAProxy"
    apt-get -y --force-yes install haproxy 2>&1 || gsn_lib_error "Unable to install HAProxy, exit status = " $?

    gsn_lib_echo "Enabling HAProxy service and logging"
    sed -i -e "s/ENABLED=0/ENABLED=1/g" /etc/default/haproxy

    # Copy files
    cp -a $CWD/config/49-haproxy.conf /etc/rsyslog.d/
  fi


  if [ ! -d /mnt/sharefs/wordpress ]; then
    gsn_lib_echo "creating wordpress and internal admin folders"
    mkdir -p /mnt/sharefs/wordpress
    mkdir -p /mnt/sharefs/admin/htdocs

    gsn_lib_echo "move the wordpress files"

    cd $GSN_GIT_HOME/wp-skeleton
    gsn_lib_echo $PWD
    rsync -avz --exclude '.g*' -exclude-from '.gitignore' ./ /mnt/sharefs/wordpress &> /dev/null
    cp -f wp-config-sample.php /mnt/sharefs/wordpress/htdocs/
    cp -f my-ms-install.php /mnt/sharefs/wordpress/htdocs/wp-admin/
    cd $CWD

    gsn_install_utils
    gsn_install_adminer

  fi

  #gsn_install_wpcli

  gsn_lib_echo "give permissions and set folders to 755 and all files to 644"
  chown -R $GSN_PHP_USER:$GSN_PHP_USER /mnt/sharefs
  # set all folders to 755 and all files to 644
  find /mnt/sharefs/ -type d -exec chmod 755 {} \;
  find /mnt/sharefs/ -type f -exec chmod 644 {} \;

  gsn_lib_echo "restart syslog for haproxy"
  restart rsyslog
}
