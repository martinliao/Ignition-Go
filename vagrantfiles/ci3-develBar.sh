#!/bin/bash

set -ex
wget -qO Develbar.zip https://github.com/martinliao/CodeIgniter-develbar/archive/refs/tags/1.2.zip
unzip Develbar.zip > /dev/null 2>&1
mv CodeIgniter-develbar* CodeIgniter-develbar

cp -r CodeIgniter-develbar/third_party/DevelBar ${DOCROOT}/application/third_party

cp DevelBarApp/DevelBarProfiler.php ${DOCROOT}/application/controllers/

cp ${DOCROOT}/application/core/MY_Loader.php ~/
cp DevelBarApp/develbar-core-MY_Loader.php ${DOCROOT}/application/core/MY_Loader.php

cat <<EOF | tee -a ${DOCROOT}/application/config/hooks.php
\$hook['display_override'][] = array(
    'class'   	=> 'Develbar',
    'function' 	=> 'debug',
    'filename' 	=> 'Develbar.php',
    'filepath' 	=> 'third_party/DevelBar/hooks'
);
EOF

cd ${DOCROOT}/application/config
sed -i "s/\(.*autoload\['packages'\][ ]\).*/\1= array\(APPPATH.'third_party\/DevelBar'\);/g" autoload.php

sed -i "s/.*config\['enable_hooks'\].*/\$config\[\'enable_hooks\'\] = TRUE;/g" config.php

sudo chown -R ${sshUsername}:www-data ${DOCROOT}

echo "*** done."