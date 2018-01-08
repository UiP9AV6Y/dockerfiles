FROM openjdk:8-jre

ENV UNIFI_HOME=/usr/lib/unifi
RUN set -xe; \
    groupadd --gid 1000 unifi \
    && useradd --uid 1000 --gid unifi --shell /bin/sh --home ${UNIFI_HOME} --create-home unifi

WORKDIR ${UNIFI_HOME}
EXPOSE 8080 8443 8880 8843 6789 3478/udp 5656-5699/udp 10001/udp

ENV UNIFI_VERSION=5.6.26
RUN set -xe; \
    curl -sSLO http://dl.ubnt.com/unifi/${UNIFI_VERSION}/unifi_sysvinit_all.deb \
    && dpkg-deb -x unifi_sysvinit_all.deb /tmp/unifi \
    && chown -R unifi:unifi /tmp/unifi \
    && cp -r \
        /tmp/unifi/${UNIFI_HOME}/* \
        ${UNIFI_HOME} \
    && rm -rf \
        unifi_sysvinit_all.deb \
        /tmp/unifi
COPY system.properties \
    ${UNIFI_HOME}/data/
COPY unifi.sh \
    /usr/local/bin/unifi

VOLUME [ \
    "${UNIFI_HOME}/data", \
    "${UNIFI_HOME}/logs", \
    "${UNIFI_HOME}/run" \
]
HEALTHCHECK --interval=5m --timeout=3s --start-period=10s \
  CMD /usr/bin/curl -f http://localhost:8080 || exit 1
CMD [ "/usr/local/bin/unifi" ]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG VERSION="1.0.0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Unifi Controller" \
    org.label-schema.description="Unifi Access Point controller" \
    org.label-schema.url="https://www.ubnt.com/" \
    org.label-schema.vcs-url=$VCS_URL \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vendor="Ubiquiti Networks, Inc." \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    com.microscaling.docker.dockerfile="/unifi-controller/Dockerfile" \
    com.microscaling.license="BSD"
