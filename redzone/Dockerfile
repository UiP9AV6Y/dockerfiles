FROM ruby:alpine

ARG REDZONE_VERSION=0.0.3
ENV REDZONE_VERSION=${REDZONE_VERSION}
RUN set -xe; \
  apk add --no-cache \
    inotify-tools \
  && gem install \
    --no-document \
    --no-user-install \
    --version "${REDZONE_VERSION}" \
    redzone

COPY bin/ \
  /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "generate-zonefiles" ]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG REVISION="0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.title="redzone" \
    org.opencontainers.image.description="RedZone is a command-line too that can generate bind zone files and configuration from yaml syntax." \
    org.opencontainers.image.url="https://github.com/justenwalker/redzone" \
    org.opencontainers.image.source=$VCS_URL \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.vendor="Justen Walker" \
    org.opencontainers.image.version="${REDZONE_VERSION}-${REVISION}" \
    com.microscaling.docker.dockerfile="/redzone/Dockerfile" \
    org.opencontainers.image.licenses="MIT"
