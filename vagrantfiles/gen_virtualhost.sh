#!/bin/bash

# Usage: DOCROOT='/var/www/html/ClassMgt' PROJECTID='ClassMgt' bash gen_virtualhost.sh
# ref: https://gist.github.com/martinliao/5632b6cc576d06fe7caa87570763b28b (參考: https://gist.github.com/srmklive/67d550cfac8bab530c69ef95a8b28d09)

cat <<EOF | sudo tee /etc/nginx/virtualhost.d/${PROJECTID}.conf;
     location /${PROJECTID} {
        #alias ${DOCROOT};
        try_files \$uri \$uri/ @${PROJECTID};

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
            fastcgi_pass unix:/run/php/php7.3-fpm.sock;
        }
    }

    location @${PROJECTID} {
        rewrite /${PROJECTID}/(.*)$ /${PROJECTID}/index.php?/\$1 last;
    }
EOF

# 在 default.conf 必須要有 include /etc/nginx/virtualhost.d/*.conf;

{ sudo nginx -t; } && { sudo systemctl restart nginx; sudo systemctl restart php7.3-fpm; }