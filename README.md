# Solidus Install Script
A Solidus Install script for Ubuntu 24.04 including optional the configuration of a Reverse Proxy and SSL.

# Introduction
This script installs Solidus including Ruby and Ruby on Rails;
in the latest maintained version on your machine;
No warranty, implied or not, is given in any way.

# Getting Started

> [!CAUTION]
> It's advised to install this script only on fresh machines, backup all files before proceeding.
> No warranties of any kind, implied or expressed are given.

```
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
sudo apt install git # The installation will be skipped if git is already present on the system
git clone https://github.com/gms-electronics/solidusinstall/
chmod +x ~/solidusinstall/installation/ubuntusolidusinstall.sh
~/solidusinstall/installation/ubuntusolidusinstall.sh
```

# Supported Configuration
Ubuntu 24.04
Solidus 4.4.2
Ruby 3.3.6
Ruby on Rails 7.2.2.1

# Features 
Following configurations are made by the script:
* Install Ruby on Rails and dependencies
* Install Solidus
* Install the DB (currently this script supports SQLite3)
* Install nginx and configure as reverse proxy (optional)
* Configure certificates with Cloudflare DNS and Let's Encrypt (optional)

# Supported Environment
A fresh Ubuntu Installation.

# Requirements
* The domain for your store should use Cloudflare DNS Hosting;
* You need a Cloudflare API Token;
* While this script might work with preexisting Rails Apps on the server, I do not recommend it. 


# Packages Installed
All packages listed below are installed in the current stable release version. Packages that are present will not be reinstalled.

## Default Installation
| Application     | Description                                                                                                |
|-----------------|------------------------------------------------------------------------------------------------------------|
| rbenv           | Sets a local application-specific Ruby versions by writing the version name to a .ruby-version file        |
| curl            | A command line tool and library for transferring data with URL syntax                                      |
| libssl-dev      | Secure Sockets Layer toolkit                                                                               |
| libreadline-dev | The GNU history library provides a consistent user interface for recalling lines of previously typed input |
| zlib1g-dev      | A compression library                                                                                      |
| autoconf        | The standard for FSF source packages                                                                       |
| bison           | Bison is a general-purpose parser generator                                                                |
| build-essential | Allows to build debian packages                                                                            |
| libyaml-dev     | A C library for parsing and emitting YAML Files                                                            |
| libncurses-dev  | Create textual user interfaces                                                                             |
| libffi-dev      | A portable foreign-function interface library                                                              |
| libgdbm-dev     | A library of database functions that use extendible hashing                                                |
| libvips         | A fast image processing library with low memory needs.                                                     |
| nodejs          | Node.js® is a JavaScript runtime built on Chrome's V8 engine.                                              |
| yarn            | A javascript package manager.                                                                              |
| redis (optional)| A memory stored DB to provide caching.                                                                     |

## Other Packages (Optional)
| Application     | Description                                                                                                |
|-----------------|------------------------------------------------------------------------------------------------------------|
| redis (optional)| A memory stored DB to provide caching.                                                                     |

## nginx (Optional)
| Application     | Description                                                                                                |
|-----------------|------------------------------------------------------------------------------------------------------------|
| nginx           | The famous webserver reverse proxying on port :3000                                                        |

## SSL Configuration

| Application     | Description                                                                                                |
|-----------------|------------------------------------------------------------------------------------------------------------|
| certbot           | Generates the SSL certificates                                                        |
| python3-certbot-dns-cloudflare         | Certbot plugin to generate certificates using DNS validation via the Cloudflare API |
| python3         | Support for Python 3 on Ubuntu|

# How will nginx be configured?
You can find the nginx configuration in the subfolder nginx of this repository.
