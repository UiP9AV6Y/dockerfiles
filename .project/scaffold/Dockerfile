FROM scratch:latest


ARG @PROJECT_CASE@_VERSION=1.0.0
ENV @PROJECT_CASE@_VERSION=$@PROJECT_CASE@_VERSION


ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG REVISION="0"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.title="" \
    org.opencontainers.image.description="" \
    org.opencontainers.image.url="" \
    org.opencontainers.image.source=$VCS_URL \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.vendor="" \
    org.opencontainers.image.version="${@PROJECT_CASE@_VERSION}-${REVISION}" \
    com.microscaling.docker.dockerfile="/@PROJECT@/Dockerfile" \
    org.opencontainers.image.licenses="GPL-3.0"
