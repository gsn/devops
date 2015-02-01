# Install PHP

function gsn_install_common()
{
  gsn_lib_echo "Installing Common Library, please wait..."
  apt-get -y --force-yes install nfs-common wget mysql-client nginx pwgen python-setuptools curl unzip \
    libssh2-php 2>&1 || gsn_lib_error "Unable to install Common Library, exit status = " $?
}
