# Install WP-CLI

function gsn_install_wpcli()
{
  dpkg --get-selections | grep -v deinstall | grep php5-fpm
  if [ ! -f /usr/local/bin/wp ];  then
    gsn_lib_echo "Downloading WP-CLI, please wait..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
  fi
}
