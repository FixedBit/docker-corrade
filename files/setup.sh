#!/usr/bin/env bash
# This script is ran inside the builx container and performs our setup
# and then deletes itself all neat and tidy.

# Stop script if we hit an error
set -e

# Setup our needed packages and install them
PACKAGES="procps tini gosu"
EXTRA_PACKAGES="unzip curl"
apt update; apt install -y --no-install-recommends $PACKAGES $EXTRA_PACKAGES

# Figure out what build arch we need to use based on buildx environment
dpkgArch="$(dpkg --print-architecture)"
ARCH=
case "${dpkgArch##*-}" in 
    amd64) ARCH='x64';; 
    arm64) ARCH='arm64';; 
    armhf) ARCH='arm';; 
    *) echo "unsupported architecture"; exit 1 ;; 
esac

# Download Corrade
curl https://corrade.grimore.org/download/corrade/linux-${ARCH}/Corrade-${CORRADE_VERSION}-linux-${ARCH}.zip --output /opt/corrade.zip

# Unpack Corrade...
unzip -q /opt/corrade.zip -d /corrade 

# Fix directories...
[ ! -d /corrade/Cache ] && mkdir /corrade/Cache
[ ! -d /corrade/State ] && mkdir /corrade/State
[ ! -d /corrade/Logs ] && mkdir /corrade/Logs
[ ! -d /corrade/Databases ] && mkdir /corrade/Databases
[ ! -d /config ] && mkdir /config

# Fixing permissions...
chown -R corrade:corrade /corrade /config

# Deleting and cleaning unneeded files...
rm -rf /opt/corrade.zip
apt autoremove -y; apt remove --purge -y $EXTRA_PACKAGES; rm -rf /var/lib/apt/lists/*

# Remove this script from container
rm -- "$0"

exit 0
