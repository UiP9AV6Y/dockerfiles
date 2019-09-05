FROM docker/compose:1.19.0

ENV SCHEDULER_HOME=/etc/crontabs
RUN set -xe; \
    rm -f ${SCHEDULER_HOME}/*

VOLUME [ \
  "${SCHEDULER_HOME}" \
]

COPY bin/ /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
HEALTHCHECK --interval=5m --timeout=3s --start-period=70s \
  CMD /usr/local/bin/crond-healthcheck.sh
CMD ["crond"]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG VERSION="1.0.0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.title="Docker-Compose Scheduler" \
    org.opencontainers.image.description="Cron scheduling for docker-compose stacks" \
    org.opencontainers.image.url="https://docs.docker.com/compose/" \
    org.opencontainers.image.source=$VCS_URL \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.vendor="Docker Inc." \
    org.opencontainers.image.version=$VERSION \
    com.microscaling.docker.dockerfile="/compose-scheduler/Dockerfile" \
    org.opencontainers.image.licenses="Apache-2.0"