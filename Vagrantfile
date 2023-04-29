# -*- mode: ruby -*-
# vi: set ft=ruby :
PHPVERSION = '7.3'
httpport = 80
PROJECTID = 'ignitionGo'
DOCROOT = '/var/www/html'

Vagrant.configure("2") do |config|
  #config.vm.box = "debian/bullseye64"
  config.vm.box = "bullseye_vb6142"
  config.ssh.insert_key = false
  config.vm.box_check_update = false
  config.vm.network "forwarded_port", guest: 80, host: "#{httpport}"
  config.vm.synced_folder ".", "/vagrant", :owner => "vagrant", :group => "vagrant"
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.gui = false
    vb.memory = 8192
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natnet1", "10.10.10/24"]
  end
  $RampUP = <<-SCRIPT
    sudo apt-get install -y -q curl dnsutils git jq gnupg2 net-tools htop python sudo wget nfs-common unzip > /tmp/apt-out 2>&1
SCRIPT
  $LNMPInstall = <<-SCRIPT
    sudo apt-get install -y apt-transport-https lsb-release ca-certificates
    sudo apt-get -y -q install nginx
    sudo systemctl status nginx
    sudo systemctl enable nginx
    wget https://packages.sury.org/php/apt.gpg -O apt.gpg && sudo apt-key add apt.gpg
    echo "deb https://packages.sury.org/php/ buster main" | sudo tee /etc/apt/sources.list.d/php.list

    sudo apt-get update
    sudo apt-get install -y php#{PHPVERSION}-fpm php#{PHPVERSION}-common php#{PHPVERSION}-cli php#{PHPVERSION}-curl php#{PHPVERSION}-gd php#{PHPVERSION}-gmp php#{PHPVERSION}-intl php#{PHPVERSION}-mbstring php#{PHPVERSION}-mysql php#{PHPVERSION}-soap php#{PHPVERSION}-xmlrpc php#{PHPVERSION}-xml php#{PHPVERSION}-zip php#{PHPVERSION}-redis php#{PHPVERSION}-ldap 
    sudo apt-get install -y default-mysql-client
    sudo apt-get install -y mariadb-server mariadb-client
    sudo systemctl start mariadb.service
    sudo systemctl enable mariadb.service
SCRIPT
  $nodejsInstall = <<-SCRIPT
    sudo apt-get install -y software-properties-common
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs

    # sudo apt-get install gcc g++ make
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update && sudo apt-get install yarn
    sudo npm install -g node-gyp grunt-cli shifter
    sudo yarn add node-sass
SCRIPT
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
  SHELL
  config.vm.provision "file", source: "vagrantfiles/dbg-wizard.php", destination: "dbg-wizard.php"
  config.vm.provision "file", source: "vagrantfiles/Codeigniter3-Patch-IGO-diff.patch", destination: "Codeigniter3-Patch-IGO-diff.patch"
  
  config.vm.define "2023" do|debian|
    debian.vm.provision :shell, inline: $RampUP
    debian.vm.provision :shell, inline: $LNMPInstall, privileged: false
    debian.vm.provision :shell, inline: <<-SHELL
      curl -Ss https://getcomposer.org/installer | php
      sudo mv composer.phar /usr/bin/composer
      composer -V
      sudo usermod -aG www-data vagrant
      echo -e "cd #{DOCROOT}" | tee -a ~/.bash_profile > /dev/null 2>&1
      echo -e "alias ll='ls \$LS_OPTIONS -l'" | tee -a ~/.bashrc > /dev/null 2>&1
      echo "set mouse-=a" | tee -a ~/.vimrc
    SHELL
    debian.vm.provision :shell, inline: $nodejsInstall
    debian.vm.provision :shell, path: "vagrantfiles/mariadb-10.5.sh"
    debian.vm.provision :shell, path: "vagrantfiles/fpm-dev.sh", privileged: false, env: {"DOCROOT" => "/var/www/html", "sshUsername" => "vagrant" }
    debian.vm.provision :shell, path: "vagrantfiles/fpm-prod.sh", privileged: false, env: {"DOCROOT" => "/var/www/html", "sshUsername" => "vagrant" }

    debian.vm.provision :shell, path: "vagrantfiles/gen_fpm_pool_conf.sh", privileged: false, env: {"PHPVERSION" => "#{PHPVERSION}", "FILESIZE" => '1024M'}

    debian.vm.provision :shell, path: "vagrantfiles/gen_defaultsite_conf.sh", privileged: false, env: {"NGINXPORT" => "#{httpport}", "DOCROOT" => "/var/www/html", "SERVERNAME" => "default", "FILESIZE" => '1024M'}
    # NGINXPORT=80 DOCROOT='/var/www/html/ci3' SERVERNAME=default FILESIZE='1024M' bash gen_defaultsite_conf.sh

    # 架 標準的 Codeigniter 3.1.13
    debian.vm.provision :shell, path: "vagrantfiles/ci3-nginx.sh", privileged: false, env: {"DOCROOT" => "/var/www/html/ci3", "PROJECTID" => "ci3", "sshUsername" => "vagrant" }
    debian.vm.provision :shell, path: "vagrantfiles/gen_virtualhost.sh", privileged: false, env: {"DOCROOT" => "/var/www/html/ci3", "PROJECTID" => "ci3", "sshUsername" => "vagrant" }

    # 架 ignition_go(https://github.com/ci-blox/Ignition-Go)
    debian.vm.provision :shell, path: "vagrantfiles/ci3-IgnitorGo.sh", privileged: false, env: {"DOCROOT" => "/var/www/html/#{PROJECTID}", "PROJECTID" => "#{PROJECTID}", "sshUsername" => "vagrant" }
    debian.vm.provision :shell, path: "vagrantfiles/gen_virtualhost_public.sh", privileged: false, env: {"DOCROOT" => "/var/www/html/#{PROJECTID}", "PROJECTID" => "#{PROJECTID}", "sshUsername" => "vagrant" }
    # DOCROOT='/var/www/html/ignition_go' PROJECTID='ignition_go' sshUsername='vagrant' bash ~/gen_virtualhost_public.sh
    # 重啟 Nginx
    debian.vm.provision :shell, inline: """
      { sudo nginx -t; } && { sudo systemctl restart nginx; sudo systemctl restart php#{PHPVERSION}-fpm; }
      sudo npm install -g bower
      # cd /var/www/html/#{PROJECTID}/
      # bower install
    """, privileged: false
    # { sudo nginx -t; } && { sudo systemctl restart nginx; sudo systemctl restart php7.3-fpm; }
    # Patch 標準的 Codeigniter 3.1.13, 把 Ignition-Go 內的 3.1.9 升級.
    debian.vm.provision :shell, inline: """
      cd /var/www/html/ci3
      patch -p0 < ~/Codeigniter3-Patch-IGO-diff.patch
      cp -r /var/www/html/ci3/system /var/www/html/#{PROJECTID}/igocore/system
    """, privileged: false  

    # 修 frontend 的 路徑 bug 及 
    # 修 gulp - primordials is not defined 問題, 實測 nodejs v14 成功.
    # ref: https://bobbyhadz.com/blog/referenceerror-primordials-is-not-defined (降nodejs 或 升 gulp?)
    debian.vm.provision :shell, privileged: false, inline: <<-SHELL
      # 1. 修 frontend 的 路徑 bug. (修完, gulp 要更新)
      cp -r /vagrant/_patch/public/assets/js/frontend.js /var/www/html/#{PROJECTID}/public/assets/js/frontend.js
      sudo npm install -g gulp-cli
      # 2. 清舊的 node_modules
      rm -rf /var/www/html/#{PROJECTID}/node_modules
      # cp /vagrant/_patch/gulp_package.json /var/www/html/#{PROJECTID}/package.json  # OR 用 jq 修改 package.json 加 resolutions 給 yarn 用.
      cd /var/www/html/#{PROJECTID}
      cat package.json | jq '.resolutions += { "graceful-fs": "^4.2.11" }' | tee -i package.json
      npm install --save-dev gulp
      gulp -v
      yarn install
      bower install
      gulp build
      echo '*** http://localhost/#{PROJECTID}/install/init 進行安裝'
    SHELL
  end
end
