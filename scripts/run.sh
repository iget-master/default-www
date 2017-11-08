#!/bin/bash

chmod -R 0777 /var/www
exec supervisord -n -c /etc/supervisor/supervisord.conf