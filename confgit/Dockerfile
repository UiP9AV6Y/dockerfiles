FROM alpine:3.7

RUN set -xe; \
  apk add --no-cache \
    ca-certificates \
    openssh-client \
    git \
  && git config --global credential.helper confgit

COPY ./bin/ /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG VERSION="1.0.0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="confgit" \
    org.label-schema.description="Configuration provider with Git backend" \
    org.label-schema.url="https://git-scm.com/" \
    org.label-schema.vcs-url=$VCS_URL \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vendor="Git community" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    com.microscaling.docker.dockerfile="/confgit/Dockerfile" \
    com.microscaling.license="LGPL-2.1"