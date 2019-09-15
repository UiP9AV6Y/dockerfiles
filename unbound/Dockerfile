FROM alpine:3.10 AS builder

ENV UNBOUND_VERSION=1.9.3
WORKDIR /src
RUN set -xe; \
  apk add --no-cache \
    dnssec-root \
    libsodium-dev \
    libevent-dev \
    libressl-dev \
    linux-headers \
    expat-dev \
    build-base \
    gnupg \
    curl \
    file \
  && curl -sSLO http://unbound.net/downloads/unbound-${UNBOUND_VERSION}.tar.gz \
  && curl -sSLO http://unbound.net/downloads/unbound-${UNBOUND_VERSION}.tar.gz.asc \
  && key='EDFAA3F2CA4E6EB05681AF8E9F6F1C2D7E045F8D' \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" \
  || gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" \
  || gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" \
  && gpg --batch --verify unbound-${UNBOUND_VERSION}.tar.gz.asc unbound-${UNBOUND_VERSION}.tar.gz \
  && rm -rf "$GNUPGHOME" unbound-${UNBOUND_VERSION}.tar.gz.asc \
  && tar -xzf unbound-${UNBOUND_VERSION}.tar.gz \
  && rm unbound-${UNBOUND_VERSION}.tar.gz \
  && cd unbound-${UNBOUND_VERSION} \
  && ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --mandir=/usr/share/man \
    --localstatedir=/var \
    --with-username=unbound \
    --with-run-dir="" \
    --with-pidfile="" \
    --with-rootkey-file=/usr/share/dnssec-root/trusted-key.key \
    --with-libevent \
    --with-pthreads \
    --disable-static \
    --disable-rpath \
    --with-ssl \
    --without-pythonmodule \
    --without-pyunbound \
    --enable-dnscrypt \
  && sed -i '/^LIBS=/s/-lpython.*[[:space:]]/ /' Makefile \
	&& make \
  && make DESTDIR="/app" install

FROM alpine:3.10

ENV UNBOUND_HOME=/etc/unbound
RUN set -xe; \
  addgroup -S unbound \
  && adduser -S -D -H -h "${UNBOUND_HOME}" -s /sbin/nologin -G unbound unbound \
  && apk add --no-cache \
    dnssec-root \
    libsodium \
    libevent \
    libressl \
    openssl \
    expat \
  && mkdir -p \
    "${UNBOUND_HOME}/conf.d" \
    "${UNBOUND_HOME}/server-conf.d" \
    "${UNBOUND_HOME}/remote-conf.d" \
    "${UNBOUND_HOME}/ssl" \
    "${UNBOUND_HOME}/aux" \
  && chown -R \
    unbound:unbound \
    "${UNBOUND_HOME}"

WORKDIR ${UNBOUND_HOME}
EXPOSE 53 53/udp 853 853/udp 8953

COPY --from=builder /app/usr/sbin/ \
  /usr/sbin/
COPY --from=builder /app/usr/lib/ \
  /usr/lib/
# minimal config which merely includes other files.
# can be mounted with a custom file in RO mode, as
# it is not modified.
COPY unbound.conf \
  ${UNBOUND_HOME}/
# opiniated defaults
COPY include.d/ \
  ${UNBOUND_HOME}/include.d/
COPY bin/ \
  /usr/local/bin/

VOLUME [ \
  "${UNBOUND_HOME}/aux", \
  "${UNBOUND_HOME}/ssl", \
  "${UNBOUND_HOME}/conf.d", \
  "${UNBOUND_HOME}/remote-conf.d", \
  "${UNBOUND_HOME}/server-conf.d" \
]
HEALTHCHECK --interval=1m --timeout=3s --start-period=10s \
  CMD /usr/sbin/unbound-control -c ${UNBOUND_HOME}/unbound.conf status -s 127.0.0.1:8953 || exit 1
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "unbound", "-c", "/etc/unbound/unbound.conf" ]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG VERSION="1.0.0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.title="Unbound" \
    org.opencontainers.image.description="Unbound is a validating, recursive, and caching DNS resolver" \
    org.opencontainers.image.url="https://unbound.net/" \
    org.opencontainers.image.source=$VCS_URL \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.vendor="NLnet Labs" \
    org.opencontainers.image.version=$VERSION \
    com.microscaling.docker.dockerfile="/Dockerfile" \
    org.opencontainers.image.licenses="BSD"
