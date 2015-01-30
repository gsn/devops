# Install PHP

function gsn_install_php()
{
  gsn_lib_echo "Installing PHP, please wait..."
  apt-get -y --force-yes install php5-common php5-mysqlnd php5-xmlrpc \
    php5-curl php5-gd php5-cli php5-fpm php5-imap php5-mcrypt php5-xdebug \
    php5-intl php-pear php5-imagick php5-ps php5-pspell php5-recode php5-snmp \
    php5-sqlite php5-tidy php5-xsl php5-memcache 2>&1 || gsn_lib_error "Unable to install PHP5, exit status = " $?
}
