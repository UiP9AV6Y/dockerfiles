FROM alpine:3.7

EXPOSE 2222

ENV REPO_ROOT=/git \
  REPO_EXAMPLE=repo.git

COPY ./sshd_config /etc/ssh/
COPY ./example-repo.sh /usr/local/bin/
COPY ./id_example.pub ${REPO_ROOT}/.ssh/authorized_keys
RUN set -xe; \
  addgroup git \
  && adduser -D -H -h "$REPO_ROOT" -s /bin/sh -G git git \
  && passwd -u git \
  && apk add --no-cache \
    git \
    openssh-server \
  && ssh-keygen -A \
  && git config --global user.email "git@example.com" \
  && git config --global user.name "Git" \
  && git init --bare --shared "${REPO_ROOT}/${REPO_EXAMPLE}" \
  && example-repo.sh "${REPO_ROOT}/${REPO_EXAMPLE}" \
  && chmod 0600 "${REPO_ROOT}/.ssh/authorized_keys" \
  && chmod 0700 "${REPO_ROOT}/.ssh" \
  && chmod 0750 "${REPO_ROOT}" \
  && chown -R git:git "${REPO_ROOT}"

ENTRYPOINT [ "/usr/sbin/sshd" ]
CMD [ "-D" ]