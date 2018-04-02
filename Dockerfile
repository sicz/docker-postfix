ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG POSTFIX_VERSION

RUN set -exo pipefail; \
# Install postfix
  apk add --no-cache \
    make \
    "postfix>${POSTFIX_VERSION}" \
    rsyslog \
    ; \
  postconf -d | grep "^mail_version"; \
  # Delete unnecessary files
  grep -l SYNOPSIS /etc/postfix/* | xargs rm -f

COPY rootfs /
RUN set -exo pipefail; \
  chmod +x \
    /etc/periodic/daily/postfix-reload \
    /etc/supervisor/wrapper/postfix

ENV \
  DOCKER_COMMAND="/usr/bin/supervisord" \
  POSTFIX_VERSION="${POSTFIX_VERSION}"
CMD ["--nodaemon", "--configuration", "/etc/supervisor/supervisord.ini"]
