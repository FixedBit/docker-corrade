FROM mono:slim

# First public publish, will add comments and clean up later

LABEL maintainer=jason@fixedbit.com

ARG CORRADE_VERSION \
    CORRADE_ZIP_URL

ENV CORRADE_UID=999 \
    CORRADE_GID=999 \
    CORRADE_USER=corrade \
    CORRADE_HOME=/corrade \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    CORRADE_VERSION=$CORRADE_VERSION

RUN groupadd --gid $CORRADE_GID $CORRADE_USER \
    && useradd -m \
       -g $CORRADE_USER \
       -d $CORRADE_HOME \
       --uid $CORRADE_UID \
       $CORRADE_USER

EXPOSE 54377 8080

ADD ./files/run.sh /sbin/run
ADD $CORRADE_ZIP_URL /opt/corrade.zip
ADD ./files/setup.sh /opt/setup.sh

RUN chmod +x /opt/setup.sh; \
    /opt/setup.sh  

VOLUME ["/config", "/corrade/Cache", "/corrade/State", "/corrade/Logs", "/corrade/Databases"]
WORKDIR /corrade

STOPSIGNAL SIGINT

ENTRYPOINT ["tini", "--", "run", "start"]
