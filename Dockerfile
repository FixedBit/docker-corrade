FROM debian:bullseye-slim
LABEL maintainer="jason@fixedbit.com"

# Build-time argument for Corrade version
ARG CORRADE_VERSION

# Set noninteractive mode and environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    CORRADE_UID=1000 \
    CORRADE_GID=1000 \
    CORRADE_USER=corrade \
    CORRADE_HOME=/corrade \
    CORRADE_VERSION=${CORRADE_VERSION} \
    CORRADE_BIND_CONFIG=false

# Add our user and group
RUN groupadd --gid ${CORRADE_GID} ${CORRADE_USER} && \
    useradd -m -g ${CORRADE_USER} -d ${CORRADE_HOME} --uid ${CORRADE_UID} ${CORRADE_USER}

# Add in our entrypoint run script
COPY ./files/run.sh /sbin/run

# ARGs are used and stored just for the container build
ARG PACKAGES="procps tini gosu libicu-dev"
ARG EXTRA_PACKAGES="unzip curl ca-certificates"

# Install packages, print status messages, download and extract Corrade, and cleanup
RUN apt-get update && \
    apt-get install -y --no-install-recommends $PACKAGES $EXTRA_PACKAGES && \
    dpkgArch="$(dpkg --print-architecture)" && \
    ARCH="" && \
    case "${dpkgArch##*-}" in \
    amd64) ARCH='x64' ;; \
    arm64) ARCH='arm64' ;; \
    armhf) ARCH='arm' ;; \
    *) echo "Unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac && \
    echo "Downloading Corrade version ${CORRADE_VERSION} for architecture ${ARCH} ..." && \
    curl -fsSL "https://corrade.grimore.org/download/corrade/linux-${ARCH}/Corrade-${CORRADE_VERSION}-linux-${ARCH}.zip" -o /opt/corrade.zip && \
    echo "Extracting Corrade version ${CORRADE_VERSION} ..." && \
    unzip -q /opt/corrade.zip -d /corrade && \
    mkdir -p /corrade/Cache /corrade/State /corrade/Logs /corrade/Databases /config && \
    chown -R ${CORRADE_USER}:${CORRADE_USER} /corrade /config && \
    rm -rf /opt/corrade.zip && \
    apt-get autoremove -y && \
    apt-get remove --purge -y $EXTRA_PACKAGES && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /sbin/run

# Setup our volumes for misc files Corrade needs
VOLUME ["/config", "/corrade/Cache", "/corrade/State", "/corrade/Logs", "/corrade/Databases"]
WORKDIR /corrade

# Expose our ports
EXPOSE 54377 8080 8085 8088 1883

# This combined with Tini allows us to intercept kill commands from Docker gracefully
STOPSIGNAL SIGINT

# Setup our entrypoint when the container runs
ENTRYPOINT ["tini", "--", "run", "start"]
