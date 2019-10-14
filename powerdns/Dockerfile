FROM alpine:3.10 AS builder

ARG FLAVOUR

ARG PDNS_VERSION=4.2.0
WORKDIR /src
RUN set -xe; \
  case "${FLAVOUR}" in \
    mysql) build_deps='mariadb-dev' ;; \
    pgsql) build_deps='postgresql-dev' ;; \
    sqlite3) build_deps='sqlite-dev' ;; \
    *) echo "unsupported flavour ${FLAVOUR}"; exit 1 ;; \
  esac \
  && apk add --no-cache \
    build-base \
    gnupg \
    curl \
    file \
    libsodium-dev \
    libressl-dev \
    boost-dev \
    p11-kit-dev \
    ${build_deps} \
&& curl -sSLO https://downloads.powerdns.com/releases/pdns-${PDNS_VERSION}.tar.bz2 \
&& curl -sSLO https://downloads.powerdns.com/releases/pdns-${PDNS_VERSION}.tar.bz2.asc \
&& keys='16E12866B7738C73976A57436FFC33439B0D04DF \
  FBAE0323821C7706A5CA151BDCF513FA7EED19F3 \
  162890D0689DD12DD33E46961C5EE990D2E71575 \
  B76CD4671C0968BAA87DE61C5E50715BF2FFE1A7' \
&& export GNUPGHOME="$(mktemp -d)" \
&& gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys $keys \
|| gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys $keys \
|| gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys $keys \
&& gpg --batch --verify pdns-${PDNS_VERSION}.tar.bz2.asc pdns-${PDNS_VERSION}.tar.bz2 \
&& rm -rf "$GNUPGHOME" pdns-${PDNS_VERSION}.tar.bz2.asc \
&& tar -xjf pdns-${PDNS_VERSION}.tar.bz2 \
&& rm pdns-${PDNS_VERSION}.tar.bz2 \
&& cd pdns-${PDNS_VERSION} \
&& LDFLAGS='-Wl,--as-needed' \
&& CFLAGS='-Os -fomit-frame-pointer' \
&& CPPFLAGS="$CFLAGS" \
&& CXXFLAGS="$CFLAGS" \
&& ./configure --prefix=/usr \
  --sysconfdir=/etc/pdns \
  --mandir=/usr/share/man \
  --infodir=/usr/share/info \
  --localstatedir=/var \
  --libdir=/usr/lib \
  --with-modules="g${FLAVOUR}" \
  --with-dynmodules="" \
  --enable-static \
  --disable-shared \
  --enable-tools \
  --enable-experimental-pkcs11 \
  --disable-dependency-tracking \
  --disable-silent-rules \
  --disable-lua-records \
  --enable-reproducible \
  'CC=gcc' \
  "LDFLAGS=${LDFLAGS}" \
  "CFLAGS=${CFLAGS}" \
  "CPPFLAGS=${CPPFLAGS}" \
  "CXXFLAGS=${CXXFLAGS}" \
&& make -j$(nproc) \
&& make DESTDIR="/app" install-strip

FROM alpine:3.10

ARG FLAVOUR

ARG PDNS_VERSION=4.2.0
ENV PDNS_VERSION=${PDNS_VERSION}
ENV PDNS_HOME=/etc/pdns
RUN set -xe; \
  addgroup -S pdns \
  && adduser -S -D -H -h ${PDNS_HOME} -s /sbin/nologin -G pdns pdns \
  && case "${FLAVOUR}" in \
    mysql) run_deps='mariadb-client mariadb-connector-c' ;; \
    pgsql) run_deps='postgresql-client postgresql-libs' ;; \
    sqlite3) run_deps='sqlite sqlite-libs' ;; \
    *) echo "unsupported flavour ${FLAVOUR}"; exit 1 ;; \
  esac \
  && apk add --no-cache \
    boost-program_options \
    libsodium \
    libressl \
    libstdc++ \
    libgcc \
    p11-kit \
    ${run_deps} \
  && mkdir -p \
    ${PDNS_HOME}/conf.d

WORKDIR ${PDNS_HOME}
EXPOSE 53 53/udp 53000 8081

COPY --from=builder /app/usr/sbin/ \
  /usr/sbin/
COPY --from=builder /app/usr/bin/ \
  /usr/bin/
COPY --from=builder /app/usr/share/doc/pdns/ \
  /usr/share/doc/pdns/
# core essentials which harmonize with the Dockerfile settings
COPY pdns.conf \
  ${PDNS_HOME}/
COPY ${FLAVOUR}.bin/ \
  /usr/local/bin/

VOLUME [ \
  "${PDNS_HOME}/conf.d", \
  "/var/run/pdns" \
]
HEALTHCHECK --interval=1m --timeout=3s --start-period=10s \
  CMD /usr/bin/pdns_control --config-dir=${PDNS_HOME} rping || exit 1
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "pdns_server" ]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG REVISION="0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.title="PowerDNS Authoritative Nameserver (${FLAVOUR} Backend)" \
    org.opencontainers.image.description="The PowerDNS Authoritative Server is a versatile nameserver which supports a large number of backends." \
    org.opencontainers.image.url="https://www.powerdns.com/" \
    org.opencontainers.image.source=$VCS_URL \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.vendor="PowerDNS.COM BV" \
    org.opencontainers.image.version="${PDNS_VERSION}-${REVISION}" \
    com.microscaling.docker.dockerfile="/powerdns/Dockerfile" \
    org.opencontainers.image.licenses="GPL-2.0"
