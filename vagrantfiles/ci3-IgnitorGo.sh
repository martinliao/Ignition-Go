#!/bin/bash

# Ignition-Go 及 Nginx site(virtualhost)的設定.
DBNAME=ci_blox

rm -rf ${DOCROOT}
cd ~/
git clone https://github.com/ci-blox/Ignition-Go.git
sudo mv Ignition-Go ${DOCROOT}
sudo chown -R ${sshUsername}:www-data ${DOCROOT}

sed -i "s/\(.*config\['composer_autoload'\][ ]\).*/\1= APPPATH . '..\/vendor\/autoload.php';/g" ${DOCROOT}/application/config/config.php

# Add virtualhost.d for virtual-host
sudo rm -rf /etc/nginx/virtualhost.d/* && sudo mkdir -p /etc/nginx/virtualhost.d/
# Add location.d for location
sudo rm -rf /etc/nginx/location.d/* && sudo mkdir -p /etc/nginx/location.d/

mysql -uroot -pjack5899 -e "Create Database IF NOT EXISTS ${DBNAME} CHARACTER SET utf8mb4 Collate utf8mb4_unicode_ci;"

## 設定 database
cd ${DOCROOT}/application/config
sed -i "s/\(.*'username'[ ]\).*/\1=> 'root',/g" database.php
sed -i "s/\(.*'password'[ ]\).*/\1=> 'jack5899',/g" database.php
sed -i "s/\(.*'database'[ ]\).*/\1=> '${DBNAME}',/g" database.php

sudo chown -R ${sshUsername}:www-data ${DOCROOT}
sudo chmod -R 775 ${DOCROOT}/application/logs
cp ${DOCROOT}/application/config/{config.php,database.php} ~/
sudo chmod 775 ${DOCROOT}/application/config/config.php
sudo chmod 775 ${DOCROOT}/application/config/database.php
sudo chmod 775 -R ${DOCROOT}/application/toolblox
sudo chmod -R 775 ${DOCROOT}/application/modules

<<comment
if [ 'true' == 'false']; then
    ## 以下為 IgnitorGO 修改標準 ci3 的部份:
    cat EOF | tee -a public/index.php

        \$igocore_path = \$path.DIRECTORY_SEPARATOR."igocore";

        // The path to the Ignition Go core folder.
        define('IGOPATH', \$igocore_path.DIRECTORY_SEPARATOR);
EOF

    cat <<EOF | tee -a ${DOCROOT}/application/config/autoload.php
    \$autoload['packages'] = array(
        realpath(APPPATH .'../igocore'),  // Ignition Go Core
        APPPATH . 'third_party',          // App -specific 3rd-party libs.
    );
EOF

    cat << EOF | tee -a ${DOCROOT}/application/config/config.php
    \$config['modules_locations'] = array(
        realpath(APPPATH) . '/modules/' => '../../application/modules/',
        realpath(IGOPATH) . '/modules/' => '../../igocore/modules/',
    );
EOF
fi
comment

echo "*** done."