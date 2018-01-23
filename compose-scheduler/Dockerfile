FROM docker/compose:1.18.0

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
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Docker-Compose Scheduler" \
    org.label-schema.description="Cron scheduling for docker-compose stacks" \
    org.label-schema.url="https://docs.docker.com/compose/" \
    org.label-schema.vcs-url=$VCS_URL \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vendor="Docker Inc." \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    com.microscaling.docker.dockerfile="/compose-scheduler/Dockerfile" \
    com.microscaling.license="Apache-2.0"