#!/bin/bash

#set -ex
# Set up Codeigniter for Nginx (server) Blocks
# ref: https://gist.github.com/yidas/30a611449992b0fac173267951e5f17f

echo "Current user: [`whoami`], Current dir: [`pwd`]..."
echo "NGINXPORT=${NGINXPORT}"
echo "DOCROOT=${DOCROOT}"
echo "SERVERNAME=${SERVERNAME}"
echo "FILESIZE=${FILESIZE}"

export PHPVERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")

if [ -f "'/etc/nginx/sites-available/${SERVERNAME}'" ]; then
    cp /etc/nginx/sites-available/${SERVERNAME} ~/${SERVERNAME}.conf
fi

cat <<EOF | sudo tee /etc/nginx/sites-available/${SERVERNAME}
server {
    listen ${NGINXPORT};
    listen [::]:${NGINXPORT};

    server_name ${SERVERNAME};
    server_tokens off;

    root ${DOCROOT};
    index index.html index.php;

    client_max_body_size ${FILESIZE};
    client_body_buffer_size ${FILESIZE};
    resolver 8.8.8.8 8.8.4.4;
    autoindex off;

    location / {
        # try_files \$uri \$uri/ =404; # backup
        # Check if a file or directory index file exists, else route it to index.php.
        try_files \$uri \$uri/ /index.php; # for Codeigniter index.php(.htaccess)
    }

    include /etc/nginx/virtualhost.d/*.conf;

    location ~ [^/].php(/|$) {
        include snippets/fastcgi-php.conf;  #fastcgi_split_path_info, #try_files 404, #fastcgi_param PATH_INFO, #fastcgi_index
        #fastcgi_pass unix:/run/php/php7.2-fpm.sock;
        fastcgi_pass unix:/run/php/php${PHPVERSION}-fpm.sock;
        # include /etc/nginx/mime.types; # in nginx.conf
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        proxy_buffer_size 16K;
        proxy_buffers 64 16k;
        fastcgi_read_timeout 300s;
        set \$realip \$remote_addr;
        if (\$http_x_forwarded_for ~ "^(\d+\.\d+\.\d+\.\d+)") {
           set \$realip \$1;
        }
        fastcgi_param REMOTE_ADDR \$realip;
        # fastcgi_param CI_ENV 'production'; // for Codeigniter
    }

    location ~ /\.ht {
        deny all;
    }

    location ~ /\. {
        access_log off;
        log_not_found off;
        deny all;
    }

    # Block (log file, binary, certificate, shell script, sql dump file) access.
    location ~* \.(log|binary|pem|enc|crt|conf|cnf|sql|sh|key)$ {
        deny all;
    }

    # Deny for accessing codes
    location ~ ^/(application|system|tests)/ {
        return 403;
    }

    include /etc/nginx/location.d/*.conf;
}
EOF

echo "Codeigniter virtual host(Nginx) setup is done."