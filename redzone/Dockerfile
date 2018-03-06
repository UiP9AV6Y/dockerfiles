FROM ruby:alpine

ENV REDZONE_VERSION=0.0.3
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
ARG VERSION="1.0.0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="redzone" \
    org.label-schema.description="RedZone is a command-line too that can generate bind zone files and configuration from yaml syntax." \
    org.label-schema.url="https://github.com/justenwalker/redzone" \
    org.label-schema.vcs-url=$VCS_URL \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vendor="Justen Walker" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    com.microscaling.docker.dockerfile="/redzone/Dockerfile" \
    com.microscaling.license="MIT"