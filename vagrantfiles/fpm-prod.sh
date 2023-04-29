#!/bin/bash

export PHPVERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")

# php.ini replate upload limit and datezone
sudo sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 2048M|' /etc/php/${PHPVERSION}/fpm/php.ini
sudo sed -i 's|post_max_size = 8M|post_max_size = 2048M|' /etc/php/${PHPVERSION}/fpm/php.ini
# add date.timezone = Asia/Taipei
sudo sed -i 's|;date.timezone =|&\ndate.timezone = Asia/Taipei|' /etc/php/${PHPVERSION}/fpm/php.ini
sudo sed -i 's|;date.timezone =|&\ndate.timezone = Asia/Taipei|' /etc/php/${PHPVERSION}/cli/php.ini
# Fix: Fatal error: Allowed memory size of 134217728 bytes exhausted
sudo sed -i 's|memory_limit[ ]=[ ].*|memory_limit = 1024M|' /etc/php/${PHPVERSION}/fpm/php.ini
sudo sed -i 's|memory_limit[ ]=[ ].*|memory_limit = 1024M|' /etc/php/${PHPVERSION}/cli/php.ini

### php.ini replate upload limit and datezone, from ModTW22
sudo sed -i 's|file_uploads[ ]*=.*|file_uploads = On|' /etc/php/${PHPVERSION}/fpm/php.ini
sudo sed -i 's|allow_url_fopen[ ]*=.*|allow_url_fopen = On|' /etc/php/${PHPVERSION}/fpm/php.ini
sudo sed -i 's|short_open_tag[ ]*=.*|short_open_tag = On|' /etc/php/${PHPVERSION}/fpm/php.ini

sudo sed -i 's|;cgi.fix_pathinfo.*|cgi.fix_pathinfo = 0|' /etc/php/${PHPVERSION}/fpm/php.ini
sudo sed -i 's|max_execution_time[ ]*=.*|max_execution_time = 360|' /etc/php/${PHPVERSION}/fpm/php.ini
# end of ModTW22

# PHP module
export PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
 # 7.2
export MODULESDIR=$(php -i | grep -P '(^|\s)extension_dir' |  awk '{print $3}')
 # /usr/lib64/php/modules

# ionCube # https://gist.github.com/JohnClickAP/07382221048117f3f88108549df6943d
cd ~/
#wget –quiet --no-verbose http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
wget –quiet --no-verbose https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xfz ioncube_loaders_lin_x86-64.tar.gz
sudo cp "ioncube/ioncube_loader_lin_${PHP_VERSION}.so" $MODULESDIR
sudo cp "ioncube/loader-wizard.php" ${DOCROOT}
sudo chown www-data ${DOCROOT}/loader-wizard.php
#sudo sed -i 's|\[PHP\]|&\nzend_extension="/usr/lib64/php/modules/ioncube_loader_lin_7.2.so"|' /etc/php/${PHPVERSION}/fpm/php.ini
export SOPATH="${MODULESDIR}/ioncube_loader_lin_${PHP_VERSION}.so"
export SEDSTRING="s|\[PHP\]|&\nzend_extension=\"$SOPATH\""
sudo sed -i "$SEDSTRING |" /etc/php/${PHPVERSION}/fpm/php.ini
sudo sed -i "$SEDSTRING |" /etc/php/${PHPVERSION}/cli/php.ini

echo "*** php${PHPVERSION}-fpm PRODUCTION environment prepare is done."
