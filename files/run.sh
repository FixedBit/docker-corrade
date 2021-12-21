#!/bin/bash

if [ -f /config/Configuration.xml ]; then
    if [ -f /corrade/Configuration.xml ]; then
    rm /corrade/Configuration.xml
    fi
    ln -s /config/Configuration.xml /corrade/Configuration.xml
fi
if [ -f /config/Nucleus.xml ]; then
    if [ -f /corrade/Nucleus.xml ]; then
    rm /corrade/Nucleus.xml
    fi
    ln -s /config/Nucleus.xml /corrade/Nucleus.xml
fi
if [ -f /config/Log4Net.config ]; then
    if [ -f /corrade/Log4Net.config ]; then
    rm /corrade/Log4Net.config
    fi
    ln -s /config/Log4Net.config /corrade/Log4Net.config
fi

case "$@" in
    start)
        echo "Starting Corrade..."
        exec gosu corrade ./Corrade
    ;;
    shell)
        exec "/bin/bash"
    ;;
    *)
        exec $@
    ;;
esac