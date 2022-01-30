#!/usr/bin/env bash
# This script is called every time the container runs and handles our init

# Check if we are binding the config files directly to the container, we default to false
if [[ "${CORRADE_BIND_CONFIG}" != "true" ]]; then
    # Remove the original files and link with our user provided configs (if found)
    echo "Fixing up Configuration.xml"
    [ -f /config/Configuration.xml ] && {
        [ -f /corrade/Configuration.xml ] && rm /corrade/Configuration.xml;
        ln -s /config/Configuration.xml /corrade/Configuration.xml;
    } || {
        [ -f /corrade/Configuration.xml.default ] && cp /corrade/Configuration.xml.default /config/Configuration.xml;
        ln -s /config/Configuration.xml /corrade/Configuration.xml;
    }

    echo "Fixing up Nucleus.xml"
    [ -f /config/Nucleus.xml ] && {
        [ -f /corrade/Nucleus.xml ] && rm /corrade/Nucleus.xml;
        ln -s /config/Nucleus.xml /corrade/Nucleus.xml;
    } || {
        [ -f /corrade/Nucleus.xml.default ] && cp /corrade/Nucleus.xml.default /config/Nucleus.xml;
        ln -s /config/Nucleus.xml /corrade/Nucleus.xml;
    }

    echo "Fixing up Log4Net.config"
    [ -f /config/Log4Net.config ] && {
        [ -f /corrade/Log4Net.config ] && rm /corrade/Log4Net.config;
        ln -s /config/Log4Net.config /corrade/Log4Net.config;
    } || {
        [ -f /corrade/Log4Net.config.default ] && cp /corrade/Log4Net.config.default /config/Log4Net.config;
        ln -s /config/Log4Net.config /corrade/Log4Net.config;
    }
# else
#     [[ -f /corrade/Log4Net.config.default && ! -f /corrade/Log4Net.config ]] && cp /corrade/Log4Net.config.default /corrade/Log4Net.config;
#     [[ -f /corrade/Configuration.xml.default && ! -f /corrade/Configuration.xml ]] && cp /corrade/Configuration.xml.default /corrade/Configuration.xml;
#     [[ -f /corrade/Nucleus.xml.default && ! -f /corrade/Nucleus.xml ]] && cp /corrade/Nucleus.xml.default /corrade/Nucleus.xml;
fi # End of CORRADE_BIND_CONFIG check

echo "Fixing Permissions on needed folders"
chown -R corrade:corrade /config /corrade/Cache /corrade/State /corrade/Logs /corrade/Databases

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