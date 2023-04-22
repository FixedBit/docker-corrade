#!/usr/bin/env bash

TESTING=false
UPLOAD=true

# Get the last tag built on docker hub
LAST_TAG=$(curl -s https://registry.hub.docker.com/v2/repositories/fixedbit/corrade/tags | jq -r '.results[1].name')

# Get the newest version of Corrade from the download page
NEWEST_VERSION=$(curl -s https://corrade.grimore.org/download/corrade/linux-x64/ | grep -o -E "Corrade[^<>]*?.zip" | tail -1 | sed 's/^Corrade-\(.*\)-linux-x64.zip$/\1/')

# If the last tag is not the newest version we run build.sh
if [ "${LAST_TAG}" != "${NEWEST_VERSION}" ] || [ "${TESTING}" = true ]; then
    echo "Last tag is not the newest version, building new image"
    BUILD_CMD='./build.sh -r fixedbit -b -c'
    # If TESTING is true we add an extra flag onto our BUILD_CMD, then we eval BUILD_CMD
    if [ "${UPLOAD}" = true ]; then
        echo "Uploading image to docker hub as latest"
        BUILD_CMD="${BUILD_CMD} -u -l"
    fi
    eval "${BUILD_CMD}"

else
    echo "Last tag is the newest version, skipping build"
fi