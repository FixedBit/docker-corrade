#!/usr/bin/env bash
# This script is sourced to get our environment variables for the build script

# We get the newest corrade zip file from the download page
export CORRADE_ZIP=$(curl -s https://corrade.grimore.org/download/corrade/linux-x64/ | grep -o -E "Corrade[^<>]*?.zip" | tail -1)
# We parse the version from it
export CORRADE_VERSION=$(echo ${CORRADE_ZIP} | sed 's/^Corrade-\(.*\)-linux-x64.zip$/\1/')
# We then pass on our tag for Docker
export DOCKER_TAG="${CORRADE_VERSION}"