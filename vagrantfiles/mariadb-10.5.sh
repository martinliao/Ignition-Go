#!/bin/bash

# The MariaDB/MySQL tools read configuration files in the following order:
# 0. "/etc/mysql/my.cnf" symlinks to this file, reason why all the rest is read.
# 1. "/etc/mysql/mariadb.cnf" (this file) to set global defaults,
# 2. "/etc/mysql/conf.d/*.cnf" to set global options.
# 3. "/etc/mysql/mariadb.conf.d/*.cnf" to set MariaDB-only options.
# 4. "~/.my.cnf" to set user-specific options.

# Full unicode support, https://docs.moodle.org/35/en/MySQL_full_unicode_support
sudo sed -i 's|\[mysqld\]|&\nskip-character-set-client-handshake|' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's|\[mysqld\]|&\ncollation-server = utf8mb4_unicode_ci|' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's|\[mysqld\]|&\ncharacter-set-server = utf8mb4|' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's|\[mysqld\]|&\ninnodb-large-prefix = 1|' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's|\[mysqld\]|&\ninnodb-file-per-table = 1|' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's|\[mysqld\]|&\ninnodb_default_row_format = DYNAMIC|' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's|\[mysqld\]|&\ninnodb-file-format = Barracuda|' /etc/mysql/mariadb.conf.d/50-server.cnf


# append text to a write protected file
# /etc/mysql/conf.d/mysql.cnf only one line: [mysql]
echo -e "default-character-set = utf8mb4\n"  | sudo tee -a /etc/mysql/conf.d/mysql.cnf
sudo sed -i 's|\[client\]|&\ndefault-character-set = utf8mb4|' /etc/mysql/mariadb.conf.d/50-client.cnf

sudo systemctl status mariadb
sudo systemctl start mariadb

mysql -u root mysql <<EOF
    Grant all privileges on *.* to 'root'@'%' identified by 'jack5899';
    Grant all privileges on *.* to 'root'@'localhost' identified by 'jack5899';
    FLUSH PRIVILEGES;
EOF

echo "*** MariaDB setup is done"




