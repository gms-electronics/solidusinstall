#!/bin/bash
# Simple Solid Store Install Script 
# © Fabian V. Thobe for GMS 2025
# Script Configuration
## Variables
solidusv=4.4.2
rubyv=3.3.6
railsv=7.2.2.1
ubuntuv=24.04
#
## Description
cat <<EOF 
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
Installs the Solidus Ecommerce Application inside the following environment:
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
echo "Your system is ready to proceed with the installation."

# Install Dependencies
cat <<EOF
----------------------------------------------------------------------------------

Step 1: Install Solidus and Dependencies

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
INFO        You might be asked for your password during this procedure.
----------------------------------------------------------------------------------
EOF

# Install Notice Ruby Dependencies and dependencies to have a smooth install
read -n 1 -s -r -p "Press CTRL + C to cancel the installation or any other key to continue."

# Install Ruby Dependencies, Rails Dependencies, certbot to have a smooth install
sudo apt install git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libncurses-dev libffi-dev libgdbm-dev libvips nodejs yarn -y

# Redis Installation
while true; do
read -p "Do you want to install Redis (recommended for Production)? (y/n)" yn
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
while true; do
read -p "Do you want skip local documentation of gem installs (recommended for development)? (y/n)" yn
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
echo "Enter the hostname of your application in the format \"server.mydomain.tld\"."
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
sudo apt install certbot python3-certbot-dns-cloudflare -y

# Configuring SSL with Certbot
read -p "Do you want to configure SSL certificates now?" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    if [ -e ~/.secrets/certbot/cloudflare.ini ]; then
        echo -e "A Cloudflare token is already configured to be used by Certbot with DNS verification using Cloudflare. \nWe will try to request a certificate using following FQDN:"
        echo $hostname
        read -n 1 -s -r -p "Press any key to continue."
        sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini --dns-cloudflare-propagation-seconds 60 -d $hostname
    else
        echo -e "Cloudflare is not yet configured to be used for Certbot, \nPlease enter your API token to configure following FQDN:"
        echo $hostname
        read cloudflaretoken
        echo "We are now creating your file with the API token, you will find it in the following file: ~/.secrets/certbot/cloudflare.ini."
        mkdir -p ~/.secrets/certbot/
        touch ~/.secrets/certbot/cloudflaretest.ini
        bash -c 'echo -e "# Cloudflare API token used by Certbot\ndns_cloudflare_api_token = $cloudflaretoken" > ~/.secrets2/certbot/cloudflare.ini'
        sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini --dns-cloudflare-propagation-seconds 60 -d $hostname
    fi
fi

# Copy over the nginx configuration and transfer the settings


echo "Step 2 is completed."