#!/bin/bash -e

### DB_UPDATE ##################################################################

# Update postfix database files on container start
if [ -n "${DOCKER_CONTAINER_START}" ]; then
  if [ -e /etc/postfix/Makefile ]; then
    info "Updating postfix database files"
    (cd /etc/postfix; make)
  fi
fi

################################################################################
