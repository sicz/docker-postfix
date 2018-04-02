#!/bin/bash -e

### POSTFIX_CERTS ##############################################################

# Use Postfix chroot dir for certs
SERVER_CRT_DIR="/etc/ssl/private"

# Postfix requires the certificate and the key to be together in one file
SERVER_CRT_FILE_MODE="400"

################################################################################
