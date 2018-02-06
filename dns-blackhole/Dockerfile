FROM python:3-alpine

ENV DNSBH_VERSION=0.12
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
ARG VERSION="1.0.0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="DNS-Blackhole" \
    org.label-schema.description="A generic DNS black hole zone generator" \
    org.label-schema.url="https://github.com/olivier-mauras/dns-blackhole" \
    org.label-schema.vcs-url=$VCS_URL \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vendor="Olivier Mauras" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    com.microscaling.docker.dockerfile="/dns-blackhole/Dockerfile" \
    com.microscaling.license="MIT"
