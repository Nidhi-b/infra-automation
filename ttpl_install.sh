#!/bin/bash

read -p "Enter non-admin username (eg: ttpl1) : "  non_admin_username
php71_name="${non_admin_username}-php71.local"
php7_name="${non_admin_username}-php7.local"
php5_name="${non_admin_username}-php5.local"
non_admin_home_dir="/home/${non_admin_username}"

if [ ! -d "$non_admin_home_dir" ]; then
  echo "Invalid username"
  exit 1
fi

if [[ -r /etc/lsb-release ]]; then
    . /etc/lsb-release
    if [[ ( $ID == "ubuntu" ) || ( $DISTRIB_ID == "Ubuntu" ) ]]; then
        echo "Running Ubuntu $UBUNTU_VERSION_NAME $DISTRIB_CODENAME"
       
        if [[ "$1" = "skip_ansible" ]]; then
          echo "Ansible is already installed" 

        else
	sudo apt-add-repository -y ppa:ansible/ansible
	sudo apt-get update
	sudo apt-get -y install ansible
        fi

	sudo wget -q https://github.com/techjoomla/infra-automation/archive/master.zip -O /tmp/master.zip
	sudo unzip -oq /tmp/master.zip -d /tmp

        if [[ "$2" = "skip_environment" ]]; then
           echo "Environment setup already exits" 
  
         else       
	sudo ansible-playbook -i "hosts," -c local /tmp/infra-automation-master/environment-setup.yml --skip-tags "createuser,ansible,aptupdate,python" --extra-vars="server_runs_as=$non_admin_username"
        fi

	sudo ansible-playbook -i "localhost," -c local /tmp/infra-automation-master/create-site.yml --extra-vars="which_host=localhost site_domain=$php5_name site_id=php5 php_install_version=5.6 server_runs_as=$non_admin_username server_runs_as_group=$non_admin_username vhost_ssl=1 site_ssl=1 ssl_selfsigned=1"
	sudo ansible-playbook -i "localhost," -c local /tmp/infra-automation-master/create-site.yml --extra-vars="which_host=localhost site_domain=$php7_name site_id=php7 php_install_version=7.0 server_runs_as=$non_admin_username server_runs_as_group=$non_admin_username vhost_ssl=1 site_ssl=1 ssl_selfsigned=1"
	sudo ansible-playbook -i "localhost," -c local /tmp/infra-automation-master/create-site.yml --extra-vars="which_host=localhost site_domain=$php71_name site_id=php71 php_install_version=7.1 server_runs_as=$non_admin_username server_runs_as_group=$non_admin_username vhost_ssl=1 site_ssl=1 ssl_selfsigned=1"	

        echo "Updating Launcher Icons"
	gsettings set com.canonical.Unity.Launcher favorites "['application://nautilus.desktop', 'application://firefox.desktop', 'application://google-chrome.desktop', 'application://geany.desktop', 'application://gnome-terminal.desktop',  'application://skype.desktop', 'application://filezilla.desktop', 'application://virtualbox.desktop', 'unity://running-apps', 'unity://expo-icon', 'unity://devices']"
     
       
    else
        echo "Not running an Ubuntu distribution. ID=$ID, VERSION=$VERSION"
    fi
else
    echo "Not running a distribution with /etc/lsb-release available"
fi
