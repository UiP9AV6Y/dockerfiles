FROM alpine:3.10

RUN set -xe; \
  apk add --no-cache \
    ca-certificates \
    openssh-client \
    git \
  && git config --global credential.helper confgit

ARG CONFGIT_VERSION=1.1.0
ENV CONFGIT_VERSION=${CONFGIT_VERSION}
COPY ./bin/ /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG REVISION="0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.title="confgit" \
    org.opencontainers.image.description="Configuration provider with Git backend" \
    org.opencontainers.image.url="https://git-scm.com/" \
    org.opencontainers.image.source=$VCS_URL \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.vendor="Git community" \
    org.opencontainers.image.version="${CONFGIT_VERSION}-${REVISION}" \
    com.microscaling.docker.dockerfile="/confgit/Dockerfile" \
    org.opencontainers.image.licenses="LGPL-2.1"
