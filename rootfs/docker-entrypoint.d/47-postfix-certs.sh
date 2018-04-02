#!/bin/bash -e

### POSTFIX_CERTS ##############################################################

# Postfix requires decrypted certificate key
if [ -e ${SERVER_CRT_FILE} -a -e ${SERVER_KEY_FILE} -a -n "${SERVER_KEY_PWD}" ]; then
  info "Decrypting postfix key ${SERVER_KEY_FILE}"
  openssl rsa -in ${SERVER_KEY_FILE} -passin pass:${SERVER_KEY_PWD} > ${SERVER_KEY_FILE}-decrypted
  SERVER_KEY_FILE="${SERVER_KEY_FILE}-decrypted"
  debug "Changing mode of ${SERVER_KEY_FILE} to ${SERVER_KEY_FILE_MODE}"
  chmod ${SERVER_KEY_FILE_MODE} ${SERVER_KEY_FILE}
fi

################################################################################
