#!/bin/sh

# Include library
source gsn_echo.sh
for gsn_include in $(find lib/ -iname "*.sh"); do
	source $gsn_include
done

apt-get update &>> /dev/null
apt-get -y upgrade &>> /dev/null

# Install Common Library
gsn_install_common

# Install PHP
gsn_install_php
gsn_setup_php
gsn_setup_nginx

# make sure opcache is enabled
php5enmod opcache
