#!/usr/bin/env bash
# This script is called every time the container runs and handles our init

# Remove the original files and link with our user provided configs (if found)
[ -f /config/Configuration.xml ] && {
    [ -f /corrade/Configuration.xml ] && rm /corrade/Configuration.xml;
    ln -s /config/Configuration.xml /corrade/Configuration.xml;
}
[ -f /config/Nucleus.xml ] && {
    [ -f /corrade/Nucleus.xml ] && rm /corrade/Nucleus.xml;
    ln -s /config/Nucleus.xml /corrade/Nucleus.xml;
}
[ -f /config/Log4Net.config ] && {
    [ -f /corrade/Log4Net.config ] && rm /corrade/Log4Net.config;
    ln -s /config/Log4Net.config /corrade/Log4Net.config;
}

# Check what command was sent to this script
case "$@" in
    start)
        echo "Starting Corrade..."
        # 'gosu' is used to spawn off as our corrade user and it supports
        # termination signals sent by Docker for a safe shutdown.
        exec gosu corrade ./Corrade
    ;;
    shell)
        # I added this here in case you want to 'bash in' :P
        exec "/bin/bash"
    ;;
    *)
        exec $@
    ;;
esac