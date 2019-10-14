FROM python:3-alpine

ARG DNSBH_VERSION=0.12
ENV DNSBH_VERSION=${DNSBH_VERSION}
RUN set -xe; \
    pip install --no-cache-dir \
      dns-blackhole==${DNSBH_VERSION} \
    && mkdir -p \
      '/var/cache/dns-blackhole' \
      '/etc/dns-blackhole'

COPY bin/ /usr/local/bin/

VOLUME [ \
    "/etc/dns-blackhole", \
    "/var/cache/dns-blackhole" \
]

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["dns-blackhole"]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG REVISION="0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.title="DNS-Blackhole" \
    org.opencontainers.image.description="A generic DNS black hole zone generator" \
    org.opencontainers.image.url="https://github.com/olivier-mauras/dns-blackhole" \
    org.opencontainers.image.source=$VCS_URL \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.vendor="Olivier Mauras" \
    org.opencontainers.image.version="${DNSBH_VERSION}-${REVISION}" \
    com.microscaling.docker.dockerfile="/dns-blackhole/Dockerfile" \
    org.opencontainers.image.licenses="MIT"
