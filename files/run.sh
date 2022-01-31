#!/usr/bin/env bash
# This script is called every time the container runs and handles our init

# Check if we are binding the config files directly to the container, we default to false
if [[ "${CORRADE_BIND_CONFIG}" != "true" ]]; then
    # Due to the new upgrade from the Corrade team, we check for old files and run the required migrations
    [ -f /config/Configuration.xml ] && { 
        echo "Performing Corrade Configuration Migration"
        mv /config/Configuration.xml /config/CorradeConfiguration.xml; 
        sed -i 's/Configuration/CorradeConfiguration/g' /config/CorradeConfiguration.xml;
    }
    [ -f /config/Nucleus.xml ] && { 
        echo "Performing Nucleus Configuration Migration"
        mv /config/Nucleus.xml /config/NucleusConfiguration.xml; 
        sed -i 's/Configuration/NucleusConfiguration/g' /config/NucleusConfiguration.xml;
    }

    # Remove the original files and link with our user provided configs (if found)
    echo "Fixing up CorradeConfiguration.xml"
    [ -f /config/CorradeConfiguration.xml ] && {
        [ -f /corrade/CorradeConfiguration.xml ] && rm /corrade/CorradeConfiguration.xml;
        ln -sf /config/CorradeConfiguration.xml /corrade/CorradeConfiguration.xml;
    } || {
        [ -f /corrade/CorradeConfiguration.xml.default ] && cp /corrade/CorradeConfiguration.xml.default /config/CorradeConfiguration.xml;
        ln -sf /config/CorradeConfiguration.xml /corrade/CorradeConfiguration.xml;
    }

    echo "Fixing up NucleusConfiguration.xml"
    [ -f /config/NucleusConfiguration.xml ] && {
        [ -f /corrade/NucleusConfiguration.xml ] && rm /corrade/NucleusConfiguration.xml;
        ln -sf /config/NucleusConfiguration.xml /corrade/NucleusConfiguration.xml;
    } || {
        [ -f /corrade/NucleusConfiguration.xml.default ] && cp /corrade/NucleusConfiguration.xml.default /config/NucleusConfiguration.xml;
        ln -sf /config/NucleusConfiguration.xml /corrade/NucleusConfiguration.xml;
    }

    echo "Fixing up Log4Net.config"
    [ -f /config/Log4Net.config ] && {
        [ -f /corrade/Log4Net.config ] && rm /corrade/Log4Net.config;
        ln -sf /config/Log4Net.config /corrade/Log4Net.config;
    } || {
        [ -f /corrade/Log4Net.config.default ] && cp /corrade/Log4Net.config.default /config/Log4Net.config;
        ln -sf /config/Log4Net.config /corrade/Log4Net.config;
    }
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