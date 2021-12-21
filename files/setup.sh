#!/bin/bash

PACKAGES="procps tini gosu"
EXTRA_PACKAGES="unzip"
apt-get update && apt-get dist-upgrade -y
apt-get install -y --no-install-recommends $PACKAGES $EXTRA_PACKAGES

echo "Unpacking corrade.zip"
unzip -q /opt/corrade.zip -d /corrade 

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

chown -R corrade:corrade /corrade /config

echo "Deleting corrade.zip"
rm -rf /opt/corrade.zip

apt-get autoremove -y
apt-get remove --purge -y $EXTRA_PACKAGES
rm -rf /var/lib/apt/lists/*

echo "Deleting ourself - Filename: $0"
rm -- "$0"

exit 0
