### POSTFIX_SETTINGS ###########################################################

# Set postfix on container start
if [ -n "${DOCKER_CONTAINER_START}" ]; then

  ### MYHOSTNAME ###############################################################

  # POSTFIX_MYHOSTNAME=host.example.com
  if [ -n "${POSTFIX_MYHOSTNAME}" ]; then
    info "Setting postfix hostname to '${POSTFIX_MYHOSTNAME}'"
    sed -E -i \
      -e "s/^#myhostname = .*/myhostname = ${POSTFIX_MYHOSTNAME}/" \
      /etc/postfix/main.cf
    : ${POSTFIX_MYDOMAIN:=$(echo "${POSTFIX_MYHOSTNAME}" | sed -E "s/^[^.]*\.//")}
  fi

  ### MYDOMAIN #################################################################

  # POSTFIX_MYDOMAIN=example.com
  if [ -n "${POSTFIX_MYDOMAIN}" ]; then
    info "Setting postfix domain to '${POSTFIX_MYDOMAIN}'"
    sed -E -i \
      -e "s/^#mydomain = .*/mydomain = ${POSTFIX_MYDOMAIN}/" \
      /etc/postfix/main.cf
  fi

  ### MYNETWORKS ###############################################################

  # POSTFIX_MYNETWORKS=192.0.2.0/24
  if [ -n "${POSTFIX_MYNETWORKS}" ]; then
    info "Setting postfix networks to '${POSTFIX_MYNETWORKS}'"
    for POSTFIX_MYNETWORK in ${POSTFIX_MYNETWORKS}; do
      echo "${POSTFIX_MYNETWORK}" >> /etc/postfix/mynetworks
    done
  fi

  ### RELAY_DOMAINS ############################################################

  # POSTFIX_RELAY_DOMAINS=example.com .example.com
  if [ -n "${POSTFIX_RELAY_DOMAINS}" ]; then
    info "Setting postfix relay domains to '${POSTFIX_RELAY_DOMAINS}'"
    for POSTFIX_RELAY_DOMAIN in ${POSTFIX_RELAY_DOMAINS}; do
      echo "${POSTFIX_RELAY_DOMAIN} RELAY" >> /etc/postfix/relay_domains
    done
  fi

  ### RELAY_HOST ###############################################################

  # POSTFIX_RELAY_HOST=[relay.example.com]
  if [ -n "${POSTFIX_RELAY_HOST}" ]; then
    info "Setting postfix relay host to '${POSTFIX_RELAY_HOST}'"
    sed -E -i \
      -e "s/^#relayhost = .*/relayhost = ${POSTFIX_RELAY_HOST}/" \
      /etc/postfix/main.cf
  fi

  ### TRANSPORT ################################################################

  # POSTFIX_TRANSPORT=example.com=relay:[relay.example.com] .example.com=relay:[relay.example.com]
  if [ -n "${POSTFIX_TRANSPORT}" ]; then
    info "Setting postfix transport to '${POSTFIX_TRANSPORT}'"
    for POSTFIX_TRANSPORT_ENTRY in ${POSTFIX_TRANSPORT}; do
      echo "${POSTFIX_TRANSPORT_ENTRY}" | sed "s/=/ /" >> /etc/postfix/transport
    done
  fi

  ### SASL_PASSWD ##############################################################

  # POSTFIX_SASL_PASSWD=relay.example.com=user:password
  if [ -n "${POSTFIX_SASL_PASSWD}" ]; then
    info "Setting postfix SASL passwords"
    for POSTFIX_SASL_PASSWD_ENTRY in ${POSTFIX_SASL_PASSWD}; do
      echo "${POSTFIX_SASL_PASSWD_ENTRY}" | sed "s/=/ /" >> /etc/postfix/sasl_passwd
    done
  fi

  ### ROOT_ALIAS ###############################################################

  # POSTFIX_ROOT_ALIAS=postmaster@example.com
  if [ -n "${POSTFIX_ROOT_ALIAS}" ]; then
    info "Setting postfix root alias to '${POSTFIX_ROOT_ALIAS}'"
    sed -E -i \
      -e "s/^#root:.*/root: ${POSTFIX_ROOT_ALIAS}/" \
      /etc/postfix/aliases
  fi

  ### DNSSEC ###################################################################

  # POSTFIX_DNSSEC=yes
  if [ -n "${POSTFIX_DNSSEC}" ]; then
    info "Enabling postfix support for DNSSEC"
    sed -E -i \
      -e "s/^smtp_dns_support_level = .*/smtp_dns_support_level = dnssec/" \
      /etc/postfix/main.cf
  fi

  ### MESSAGE_SIZE_LIMIT #######################################################

  # POSTFIX_MESSAGE_SIZE_LIMIT=20971520
  if [ -n "${POSTFIX_MESSAGE_SIZE_LIMIT}" ]; then
    info "Setting postfix message size limit to ${POSTFIX_MESSAGE_SIZE_LIMIT}"
    sed -E -i \
      -e "s/^message_size_limit = .*/message_size_limit = ${POSTFIX_MESSAGE_SIZE_LIMIT}/" \
      /etc/postfix/main.cf
  fi

  ### STARTTLS #################################################################

  if [ -e ${SERVER_CRT_FILE} -a -e ${SERVER_KEY_FILE} ]; then
    info "Setting STARTTLS certificate ${SERVER_CRT_FILE} and key ${SERVER_KEY_FILE}"
    sed -E -i \
      -e "s|^smtp_use_tls = .*|smtp_use_tls = yes|" \
      -e "s|^smtp_tls_cert_file = .*|smtp_tls_cert_file = ${SERVER_CRT_FILE}|" \
      -e "s|^smtp_tls_key_file = .*|smtp_tls_key_file = ${SERVER_KEY_FILE}|" \
      -e "s|^smtpd_use_tls = .*|smtpd_use_tls = yes|" \
      -e "s|^smtpd_tls_cert_file = .*|smtpd_tls_cert_file = ${SERVER_CRT_FILE}|" \
      -e "s|^smtpd_tls_key_file = .*|smtpd_tls_key_file = ${SERVER_KEY_FILE}|" \
      /etc/postfix/main.cf
  fi

  ### RSPAMD_MILTER ############################################################

  # POSTFIX_RSPAMD_MILTER=inet:rspamd.local:11332
  if [ -n "${POSTFIX_RSPAMD_MILTER}" ]; then
    info "Setting Rspamd milter '${POSTFIX_RSPAMD_MILTER}'"
    sed -E -i \
      -e "s/^#smtpd_milters = .*/smtpd_milters = ${POSTFIX_RSPAMD_MILTER}/" \
      /etc/postfix/main.cf
  fi

  ### POSTSCREEN ###############################################################

  info "Enabling postscreen"
  sed -E -i \
    -e "s/^(smtp .* smtpd)/#\1/" \
    -e "s/#(smtp .* postscreen)/\1/" \
    -e "s/#(smtpd .* smtpd)/\1/" \
    /etc/postfix/master.cf

  ##############################################################################

fi

################################################################################
