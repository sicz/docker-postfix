all: aliases.db recipient_access.db relay_domains.db sender_access.db sasl_passwd.db transport.db

.PHONY: reload

aliases.db: aliases
	postalias $?

recipient_access.db: recipient_access
	postmap $?

relay_domains.db: relay_domains
	postmap $?

sasl_passwd.db: sasl_passwd
	postmap $?

sender_access.db: sender_access
	postmap $?

transport.db: transport
	postmap $?

reload:
	postfix reload
