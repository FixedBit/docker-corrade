#!/usr/bin/env bash

export CORRADE_ZIP=$(curl -s https://corrade.grimore.org/download/corrade/linux-x64/ | grep -o -E "Corrade[^<>]*?.zip" | tail -1)
export CORRADE_VERSION=$(echo ${CORRADE_ZIP} | sed 's/^Corrade-\(.*\)-linux-x64.zip$/\1/')
export DOCKER_TAG="${CORRADE_VERSION}"