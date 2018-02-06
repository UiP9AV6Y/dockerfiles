FROM alpine:3.7

RUN set -xe; \
  apk add --no-cache \
    bind-tools

COPY ./usage.sh /usr/local/bin/

CMD [ "/usr/local/bin/usage.sh" ]