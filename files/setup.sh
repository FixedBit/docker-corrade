#!/bin/bash

set -e

PACKAGES="procps tini gosu"
EXTRA_PACKAGES="unzip curl"
apt-get update && apt-get dist-upgrade -y
apt-get install -y --no-install-recommends $PACKAGES $EXTRA_PACKAGES

dpkgArch="$(dpkg --print-architecture)"
ARCH=
case "${dpkgArch##*-}" in 
    amd64) ARCH='x64';; 
    arm64) ARCH='arm64';; 
    armhf) ARCH='arm';; 
    *) echo "unsupported architecture"; exit 1 ;; 
esac

echo "Downloading Corrade URL: https://corrade.grimore.org/download/corrade/linux-${ARCH}/Corrade-${CORRADE_VERSION}-linux-${ARCH}.zip"
curl https://corrade.grimore.org/download/corrade/linux-${ARCH}/Corrade-${CORRADE_VERSION}-linux-${ARCH}.zip --output /opt/corrade.zip

echo "Unpacking Corrade..."
unzip /opt/corrade.zip -d /corrade 

echo "Fixing directories..."
if [ ! -d /corrade/Cache ]; then
    mkdir /corrade/Cache
fi
if [ ! -d /corrade/State ]; then
    mkdir /corrade/State
fi
if [ ! -d /corrade/Logs ]; then
    mkdir /corrade/Logs
fi
if [ ! -d /corrade/Databases ]; then
    mkdir /corrade/Databases
fi
if [ ! -d /config ]; then
    mkdir /config
fi

echo "Fixing permissions..."
chown -R corrade:corrade /corrade /config

echo "Deleting unneeded files..."
rm -rf /opt/corrade.zip

echo "Cleaning up APT..."
apt-get autoremove -y
apt-get remove --purge -y $EXTRA_PACKAGES
rm -rf /var/lib/apt/lists/*

echo "Deleting ourself - Filename: $0"
rm -- "$0"

exit 0
