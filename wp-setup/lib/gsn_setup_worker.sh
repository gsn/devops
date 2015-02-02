# Install worker server

function gsn_setup_worker()
{
  if [ ! -d /mnt/sharefs ]; then
    gsn_lib_echo "create a directory for the shared data"
    mkdir -p /mnt/sharefs

    gsn_lib_echo "give permissions and set folders to 755 and all files to 644"
    chown -R $GSN_PHP_USER:$GSN_PHP_USER /mnt/sharefs
    # set all folders to 755 and all files to 644
    find /mnt/sharefs/ -type d -exec chmod 755 {} \;
    find /mnt/sharefs/ -type f -exec chmod 644 {} \;

    gsn_lib_echo "Enter the IP or domain of the admin box where the shared volume is:"
    read -e -p "Enter admin domain or IP:" -i "wpa.gsngrocers.com" ADMIN_SERVER

    gsn_lib_echo "set automatic mounting in case of reboot"
    echo "$ADMIN_SERVER:/mnt/sharefs /mnt/sharefs nfs4 bg,hard,intr,rsize=8192,wsize=8192,nosuid" >> /etc/fstab
    mount -a
  fi
}
