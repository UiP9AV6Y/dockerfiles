FROM python:3-alpine3.10

ARG CROND_RELEASE=20.7.0
ENV CURATOR_CRON_D=/data
ADD "https://github.com/webdevops/go-crond/releases/download/${CROND_RELEASE}/go-crond-64-linux" /usr/local/bin/crond
RUN set -xe; \
  chmod +x /usr/local/bin/crond \
  && install -m 0777 -d "${CURATOR_CRON_D}"

ARG CURATOR_VERSION=5.8.1
ENV CURATOR_VERSION=${CURATOR_VERSION}
RUN set -xe; \
  pip install --no-cache-dir \
    elasticsearch-curator==${CURATOR_VERSION}

COPY bin/ \
  /usr/local/bin/

USER daemon
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["crond", "--allow-unprivileged"]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG REVISION="0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.title="Curator" \
    org.opencontainers.image.description="Elasticsearch Curator helps you curate, or manage, your Elasticsearch indices and snapshots" \
    org.opencontainers.image.url="https://github.com/elastic/curator" \
    org.opencontainers.image.source=$VCS_URL \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.vendor="Elasticsearch B.V." \
    org.opencontainers.image.version="${CURATOR_VERSION}-${REVISION}" \
    com.microscaling.docker.dockerfile="/curator-cron/Dockerfile" \
    org.opencontainers.image.licenses="Apache-2.0"
