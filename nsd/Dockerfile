FROM alpine:3.7 AS builder

ENV NSD_VERSION=4.1.26
WORKDIR /src
RUN set -xe; \
  apk add --no-cache \
    libevent-dev \
    libressl-dev \
    build-base \
    gnupg \
    curl \
    file \
  && curl -sSLO https://www.nlnetlabs.nl/downloads/nsd/nsd-${NSD_VERSION}.tar.gz \
  && curl -sSLO https://www.nlnetlabs.nl/downloads/nsd/nsd-${NSD_VERSION}.tar.gz.asc \
  && key='EDFAA3F2CA4E6EB05681AF8E9F6F1C2D7E045F8D' \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" \
  || gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" \
  || gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" \
  && gpg --batch --verify nsd-${NSD_VERSION}.tar.gz.asc nsd-${NSD_VERSION}.tar.gz \
  && rm -rf "$GNUPGHOME" nsd-${NSD_VERSION}.tar.gz.asc \
  && tar -xzf nsd-${NSD_VERSION}.tar.gz \
  && rm nsd-${NSD_VERSION}.tar.gz \
  && cd nsd-${NSD_VERSION} \
  && ./configure \
    --sbindir=/usr/sbin \
    --mandir=/usr/share/man \
    --with-user=nsd \
    --with-pidfile=/var/run/nsd/nsd.pid \
    --with-xfrdir=/var/db/nsd \
    --with-ssl \
    --with-libevent \
    --enable-ratelimit \
    --enable-ratelimit-default-is-off \
    --enable-bind8-stats \
    --enable-zone-stats \
    CFLAGS="-O2 -flto -fPIE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security" \
    LDFLAGS="-Wl,-z,now -Wl,-z,relro" \
	&& make \
  && make DESTDIR="/app" install

FROM alpine:3.7

ENV NSD_HOME=/etc/nsd
RUN set -xe; \
  addgroup -S nsd \
  && adduser -S -D -H -h ${NSD_HOME} -s /sbin/nologin -G nsd nsd \
  && apk add --no-cache \
    libevent \
    libressl \
    openssl \
  && install -d \
    -o nsd \
    -g nsd \
    /var/db/nsd \
    /var/run/nsd \
    ${NSD_HOME}/ssl \
    ${NSD_HOME}/conf.d

WORKDIR ${NSD_HOME}
EXPOSE 53 53/udp 8952

COPY --from=builder /app/usr/sbin/ \
  /usr/sbin/
# core essentials which harmonize with the Dockerfile settings
COPY nsd.conf \
  ${NSD_HOME}/
# opiniated defaults
COPY server-config/ \
  ${NSD_HOME}/server-conf.d/
COPY bin/ \
  /usr/local/bin/

VOLUME [ \
  "/var/db/nsd", \
  "${NSD_HOME}/ssl", \
  "${NSD_HOME}/conf.d", \
  "${NSD_HOME}/server-conf.d" \
]
HEALTHCHECK --interval=1m --timeout=3s --start-period=10s \
  CMD /usr/sbin/nsd-control -c ${NSD_HOME}/nsd.conf status -s 127.0.0.1:8952 || exit 1
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "nsd", "-c", "/etc/nsd/nsd.conf" ]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG VERSION="1.0.0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="NSD" \
    org.label-schema.description="NSD is an authoritative only, high performance, simple and open source name server." \
    org.label-schema.url="https://www.nlnetlabs.nl/projects/nsd/" \
    org.label-schema.vcs-url=$VCS_URL \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vendor="NLnet Labs" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    com.microscaling.docker.dockerfile="/nsd/Dockerfile" \
    com.microscaling.license="BSD"