#!/bin/bash

export PHPVERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")

# debug: dbg-wizard
cd ${DOCROOT} && sudo wget --quiet http://shop.nusphere.com/customer/download/files/dbg-wizard.php
sudo wget --quiet https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql-en.php -O adminer.php
sudo chown www-data adminer.php dbg-wizard.php

# dbg-sample.php
sudo -H -u root /bin/bash << 'SCRIPT'
  cat <<EOT >> ${DOCROOT}/dbg-sample.php
<?php 
function test_func(&\$arg1) { 
  var_dump(\$arg1); 
  return "hello"; 
} 
 
  \$tst = array(0=>"element1", "a"=>"element2"); 
  \$a = test_func(\$tst); 
  echo "\$a world"; 
EOT
  chown ${sshUsername}:www-data ${DOCROOT}/dbg-sample.php
SCRIPT

# PHP module
export PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
 # 7.2
export MODULESDIR=$(php -i | grep -P '(^|\s)extension_dir' |  awk '{print $3}')
 # /usr/lib64/php/modules
cd ~/
# debug: dbg-php.so
wget –quiet --no-verbose https://www.dropbox.com/s/5ekcoclgly9lykk/dbg-9.3.4-Linux.tar.gz?dl=0 -O dbg-9-Linux.tar.gz
# eg. ~/dbg-8.2.9-Linux/x86_64/dbg-php-7.2.so $MODULESDIR/
tar -zxf dbg-9-Linux.tar.gz
sudo cp ~/dbg-9.3.4-Linux/x86_64/dbg-php-$PHP_VERSION.so $MODULESDIR

# eg. /usr/lib/php/20180731/dbg-php-7.3.so
cat <<EOF | sudo tee /etc/php/${PHP_VERSION}/mods-available/dbg.ini
; configuration for dbg module
; zend_extension="${MODULESDIR}/dbg-php-${PHP_VERSION}.so"
zend_extension=dbg-php-${PHP_VERSION}.so
[debugger]
debugger.hosts_allow= 10.10.10.2 10.0.2.2 localhost ::1 127.0.0.1
debugger.hosts_deny=ALL
debugger.ports=7869
EOF

# sudo ln -s /etc/php/7.3/mods-available/dbg.ini /etc/php/7.3/fpm/conf.d/dbg.ini
#sudo ln -s /etc/php/${PHP_VERSION}/mods-available/dbg.ini /etc/php/${PHP_VERSION}/cli/conf.d/dbg.ini
sudo ln -s /etc/php/${PHP_VERSION}/mods-available/dbg.ini /etc/php/${PHP_VERSION}/fpm/conf.d/dbg.ini

sudo systemctl restart php7.3-fpm

cat <<EOF | sudo tee ${DOCROOT}/pi.php
<?php      
  phpinfo();
EOF

sudo chown -R ${sshUsername}:www-data ${DOCROOT}

echo "*** php${PHPVERSION}-fpm DEVELOPMENT environment prepare is done."