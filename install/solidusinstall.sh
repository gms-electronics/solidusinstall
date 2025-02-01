#!/bin/bash
# Simple Solid Store Install Script 
# © Fabian V. Thobe for GMS 2025 If no license specified in parent repository, all rights reserved.
# Script Configuration
## Variables
### Versions and EOL dates
solidusv=4.4.2
soliduseol=2026-05-06
rubyv=3.3.6
rubyeol=2027-03-31
railsv=7.2.2.1
railseol=2026-08-9
ubuntuv=24.04
ubuntueol=2029-04-01
cat <<EOF \

----------------------------------------------------------------------------------
© 2025 Fabian Vincent Thobe for GMS
If not specified in parent repository, all rights reserved.
----------------------------------------------------------------------------------
   █████                                                       
 ██████████      █████   █████  █      █  █████   █    █  █████
 ███    █        █      █     █ █      █  █    █  █    █  █    
  ███   ██         █    █     █ █      █  █    █  █    █    █
    █   ███          █  █     █ █      █  █    █  █    █      █ 
 ██████████      █████   █████  █████  █  █████   ██████  █████ 
   █████                                                                                                     
----------------------------------------------------------------------------------
Solidus Install Script for Stable Release with reverse proxy and SSL configuration
----------------------------------------------------------------------------------
Solidus $solidusv powered by Ruby $rubyv and Rails $railsv running on Ubuntu $ubuntuv
----------------------------------------------------------------------------------
This script installs Solidus including Ruby and Ruby on Rails
in the latest maintained version on your machine.
No warranty, implied or not, is given in any way.

Features: 

* Install Ruby on Rails and dependencies
* Install Solidus
* Install the DB (currently this script supports SQLite3)
* Install nginx and configure as reverse proxy (optional)
* Configure certificates with Cloudflare DNS and Let's Encrypt (optional)

Solidus Configuration: 

* New Solidus Promotions System
* New Solidus Backend

Security Lifetime of the Components:

* Solidus $solidusv support ends on $soliduseol
* Ruby $rubyv support ends on $rubyeol
* Rails $railsv support ends on $railseol
* Ubuntu $ubuntuv support ends on $ubuntueol

----------------------------------------------------------------------------------
Information         You might be asked for your password during this procedure.
----------------------------------------------------------------------------------
EOF

## Description
echo -e "To normalize and prepare your system Ubuntu we will update installed packages.\nDo not proceed if you need to backup data before."
read -n 1 -s -r -p "Press CTRL + C to cancel the installation or any other key to continue."

# Get a clean slate by updating Ubuntu (apt update & sudo apt upgrade)
echo "Please enter your password to upgrade Ubuntu. During this process we will update all packages on Ubuntu."
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
echo "Your system is up to date and ready to proceed with the installation."

# Install Dependencies
# [WIP] Convert text block to array
cat <<EOF
----------------------------------------------------------------------------------

Step 1: Install Solidus and Dependencies (sudo might be required for some steps)

----------------------------------------------------------------------------------

We will now install everything needed to run Solidus.
Packages that are already present on the system will be skipped automatically.
This script assumes a very basic installation containing following packages:

* git               A distributed version control system
* curl              A command line tool and library for transferring data
                    with URL syntax
* libssl-dev        Secure Sockets Layer toolkit
* libreadline-dev   The GNU history library provides a consistent user interface
                    for recalling lines of previously typed input.
* zlib1g-dev        A compression library
* autoconf          The standard for FSF source packages. 
* bison             Bison is a general-purpose parser generator.
* build-essential   Allows to build debian packages
* libyaml-dev       A C library for parsing and emitting YAML Files
* libncurses-dev    Create textual user interfaces
* libffi-dev        A portable foreign-function interface library.
* libgdbm-dev       A library of database functions that use extendible hashing
* libvips           A fast image processing library with low memory needs. 
* nodejs            Node.js® is a JavaScript runtime built on Chrome's V8 engine.
* yarn              A javascript package manager.
* redis (optional)  A memory stored DB to provide caching.

----------------------------------------------------------------------------------
INFO                You might be asked for your password during this procedure.
----------------------------------------------------------------------------------
EOF

# Install Notice Ruby Dependencies and dependencies to have a smooth install
read -n 1 -s -r -p "Press CTRL + C to cancel the installation or any other key to continue."

# Install Ruby Dependencies, Rails Dependencies, certbot to have a smooth install
sudo apt install git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libncurses-dev libffi-dev libgdbm-dev libvips nodejs yarn -y

# Redis Installation
# [WIP] Unify all Yes / No questions in single paradigm
while true; do
read -p "Do you want to install Redis (recommended for Production)?" yn
echo -e "Answer with \"y/n\"."
echo    # (optional) move to a new line
case $yn in 
	[yY] ) sudo apt install redis -y;
		break;;
	[nN] ) echo "Ok, we won't install Redis.";
		break;;
	* ) echo "Your response was invalid, reply with \"y\" or \"n\".";;
esac

done

echo "Proceeding with the installation..."

# Install rbenv from the official install script and add rbenv and enabling it for this and future sessions
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install Ruby and configure supported version globally
rbenv install $rubyv
rbenv global $rubyv

# Skips local documentation of gem installs
# [WIP] Unify all Yes / No questions in single paradigm
while true; do
read -p "Do you want skip local documentation of gem installs (recommended for development)? (y/n)" yn
echo -e "Answer with \"y/n\"."
echo    # (optional) move to a new line
case $yn in 
	[yY] ) echo "gem: --no-document" > ~/.gemrc;
		break;;
	[nN] ) echo "Ok, we won't skip local documentation.";
		break;;
	* ) echo "Your response was invalid, reply with \"y\" or \"n\".";;
esac

done

echo "Proceeding with the installation..."

# Installs bundler 
gem install bundler

# Install Rails
gem install rails -v $railsv
rbenv rehash

# Asking user to enter FQDN of rails app
echo "By now Ruby, Ruby on Rails and Redis are installed."
echo "Enter the hostname of your application in the format \"hostname.example.com\"."
echo "An application folder will be created and the server name will be used to create also your SSL certificates and configure nginx."
read hostname

# Install DB
# Install SQLite3
# [WIP] DB Configuration (allow also Postgre and MySQL)
sudo apt install sqlite3 -y

# Setup a new rails app with the hostname as app name and installs solidus
rails new -T $hostname
cd ~/$hostname
bundle add solidus

# Install Nginx and configure reverse proxy
cat <<EOF
----------------------------------------------------------------------------------

Step 2: Solidus Reverse Proxy Configuration with SSL using nginx and certbot

----------------------------------------------------------------------------------

You have now the possibility to install and configure a reverse proxy.
Your password might be required for this procedure. 
If pre-existing certificates or configurations are found, 
this script will try to reuse them. 

Requirements for SSL (optional):
* The domain must use the Cloudflare DNS Servers,
* You need a Cloudflare API Token.

Packages that will be installed: 
* nginx (current stable release),

Packages that will be installed if you chose to configure SSL (optional): 
* certbot (current stable release),
* python3-certbot-dns-cloudflare (current stable release),
* Python 3 (current stable release) will be installed if not found on the system.

----------------------------------------------------------------------------------
            Hosting the Cloudflare API token on a server exposed to the web is not
WARNING     advised. Consider moving the Cloudflare token to a different system
            afterwards and generate certificates externally.
----------------------------------------------------------------------------------
INFO        You might be asked for your password during this procedure. 
----------------------------------------------------------------------------------
EOF

# Install nginx
sudo apt install nginx -y

# Install SSL Requierements
sudo apt install certbot python3 python3-certbot-dns-cloudflare -y

# Configuring SSL with Certbot
read -p "Do you want to configure SSL certificates now?" -n 1 -r
echo -e "Answer with \"y/n\"."
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    if [ -e ~/.secrets/certbot/cloudflare.ini ]; then
        echo -e "A Cloudflare token is already configured to be used by Certbot with DNS verification using Cloudflare. \nWe will try to request a certificate using following FQDN:"
        echo $hostname
        read -n 1 -s -r -p "Press any key to continue."
        sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini --dns-cloudflare-propagation-seconds 60 -d $hostname
    else
        echo -e "Cloudflare is not yet configured to be used for Certbot, \nPlease enter your Cloudflare API token to configure following FQDN: $hostname"
        read cloudflaretoken
        echo "We are now creating your file with the API token, you will find it in the following file: ~/.secrets/certbot/cloudflare.ini."
        mkdir -p ~/.secrets/certbot/
        touch ~/.secrets/certbot/cloudflaretest.ini
        bash -c 'echo -e "# Cloudflare API token used by Certbot\ndns_cloudflare_api_token = $cloudflaretoken" > ~/.secrets2/certbot/cloudflare.ini'
        sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini --dns-cloudflare-propagation-seconds 60 -d $hostname
    fi
fi

# [WIP]Copy over the nginx configuration and transfer the settings

echo "Step 2 is completed."

# Firewall Configuration

cat <<EOF 
----------------------------------------------------------------------------------

Step 3: Firewall Configuration (optional)

----------------------------------------------------------------------------------

 ▗▖ ▗▖ ▗▄▖ ▗▄▄▖ ▗▖  ▗▖▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖
 ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▛▚▖▐▌  █  ▐▛▚▖▐▌▐▌   
 ▐▌ ▐▌▐▛▀▜▌▐▛▀▚▖▐▌ ▝▜▌  █  ▐▌ ▝▜▌▐▌▝▜▌
 ▐▙█▟▌▐▌ ▐▌▐▌ ▐▌▐▌  ▐▌▗▄█▄▖▐▌  ▐▌▝▚▄▞▘
                                                                                
You can now configure the firewall.
Please not that the following configuration might break your access 
to this server. Act very carefully and skip this step if you do not
know what you are doing. 

Default Configuration:
* We will keep ports 22 (SSH) and 443 (https) open
* All other ports will be closed

Development Configuration (optional): 
* Also port 3000 (http access for your solidus store) will be opened

----------------------------------------------------------------------------------
            If you use any other port than 22 for SSH access you won't reach
            this system any more. Please assure that you have access to this
WARNING     machine using traditional ports and that you didn move the SSH port.
            You will receive a separate warnign during the configuration of 
            of the Firewall that you can accept if you are running SSH on port 22.
----------------------------------------------------------------------------------
INFO        You might be asked for your password during this procedure. 
----------------------------------------------------------------------------------
EOF

echo -e "This part is work in progress."

# while true; do
# read -p "Do you want to activate the firewall leaving ports 22 and 443 accessible? " yn
# echo    # (optional) move to a new line
# case $yn in 
# 	[yY] )  echo -e "We will configure the firewall now."
#          echo -e "You might be asked for your password during this procedure."
#          sudo ufw allow OpenSSH
#          sudo ufw allow Nginx HTTPS
#          sudo ufw default deny incoming
#          sudo ufw default allow outgoing
#          sudo ufw enable
#          echo -e "The Firewall is now active.";
# 		break;;
#	[nN] )  echo -e "The firewall will not be activated.";
#		break;;
# 	* ) echo "Your response was invalid, reply with \"y\" or \"n\".";;
# esac
# 
# done


# Redis Installation Start
cat <<EOF 
----------------------------------------------------------------------------------

Step 4: Redis Configuration (optional)

----------------------------------------------------------------------------------
                                                    
We will now configure Redis. 
Please not that the following configuration might break your access 
to this server. Act very carefully and skip this step if you do not
know what you are doing. 

Default Configuration:
* We will keep ports 22 (SSH) and 443 (https) open
* All other ports will be closed

Development Configuration (optional): 
* Also port 3000 (http access for your solidus store) will be opened

----------------------------------------------------------------------------------
            If you use any other port than 22 for SSH access you won't reach
            this system any more. Please assure that you have access to this
WARNING     machine using traditional ports and that you didn move the SSH port.
            You will receive a separate warnign during the configuration of 
            of the Firewall that you can accept if you are running SSH on port 22.
----------------------------------------------------------------------------------
INFO        You might be asked for your password during this procedure. 
----------------------------------------------------------------------------------
EOF

while true; do
read -p "Do you want to install and configure Redis? " yn
echo    # (optional) move to a new line
case $yn in 
 	[yY] )  echo -e "We will configure Redis now."
          echo -e "You might be asked for your password during this procedure."
          sudo apt install redis-server
          sudo bash -c 'echo -e "supervised systemd" >> /etc/redis/redis.conf'
          sudo systemctl restart redis
          cd ~/$hostname$
          gem redis
          gem sidekiq
          gem bundle
          echo -e "\n# Solidus Install Script Additions\ngem \"redis\"\ngem \"sidekiq\"" >> ~/$hostname/Gemfile
          cat <<EOL > ~/$hostname/config/initializers/sidekiq.rb
          Sidekiq.configure_server do |config|
            config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
          end

          Sidekiq.configure_client do |config|
            config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
          end
          EOL
          echo -e "\n\n# Solidus Install Script Additions\nconfig.active_job.queue_adapter = :sidekiq" >> config/application.rb
          echo -e "We have configured Redis.";
 		      break;;
	[nN] )  echo -e "The installation of Redis has been skipped.";
		      break;;
 	* )     echo "Your response was invalid, reply with \"y\" or \"n\".";;
esac
 
done


# [WIP] Sidekiq configuration
# echo -e "We have installed solidus."
# sed -i '/class Application < Rails::Application/a\ \ \ \ config.active_job.queue_adapter = :sidekiq' config/application.rb
# sed -i '/class Application < Rails::Application/,/end/ { /end/ i \    # Solidus Install Script Additions\n    config.active_job.queue_adapter = :sidekiq' }' config/application.rb