#!/usr/bin/env bash

# Clean up sites-enabled
echo "Clean sites-enabled"
rm -rf /etc/nginx/conf.d/*.conf
mkdir -p /etc/nginx/conf.d

if [ $# -eq 1 ]; then
	case $1 in
		# Production mode, run using uwsgi
		[Pp][Rr][Oo][Dd])
			echo "Run in prod mode"
			CONF_FILE=prod.conf
			ln -s /etc/nginx/sites-available/$CONF_FILE /etc/nginx/conf.d/$CONF_FILE
			exec nginx -g "daemon off;"
			;;
		# Production SSL mode, run using uwsgi
		[Pp][Rr][Oo][Dd][-][Ss][Ss][Ll])
			echo "Run in prod SSL mode"
			CONF_FILE=prod-ssl.conf
			ln -s /etc/nginx/sites-available/$CONF_FILE /etc/nginx/conf.d/$CONF_FILE
			exec nginx -g "daemon off;"
			;;
		# Staging mode, run using uwsgi
		[Ss][Tt][Aa][Gg][Ii][Nn][Gg])
			echo "Run in staging mode"
			CONF_FILE=staging.conf
			ln -s /etc/nginx/sites-available/$CONF_FILE /etc/nginx/conf.d/$CONF_FILE
			exec nginx -g "daemon off;"
			;;
	esac
fi

# Run as bash entrypoint
exec "$@"
