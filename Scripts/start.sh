#!/bin/bash

# SSH
/etc/init.d/ssh restart

# Install Extras
if [ ! -z "$DEBS" ]; then
  apt-get update
  apt-get install -y $DEBS
fi

# NGINX
procs=$(cat /proc/cpuinfo | grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

# Dirty Hack
if [[ "$TEMPLATE_NGINX_HTML" == "1" ]]; then
  for i in $(env)
  do
    variable=$(echo "$i" | cut -d'=' -f1)
    value=$(echo "$i" | cut -d'=' -f2)
    if [[ "$variable" != '%s' ]]; then
      replace='\$\$_'${variable}'_\$\$'
    find /app -type f -exec sed -i -e 's/'${replace}'/'${value}'/g' {} \;
    fi
  done
fi

# Permissions
chown -Rf www-data:www-data /app

# Supervisor keep in memory
unlink /tmp/supervisor.sock
/usr/bin/supervisord -n -c /etc/supervisord.conf
