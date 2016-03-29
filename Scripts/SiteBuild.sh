#!/bin/bash
/etc/init.d/ssh restart

# Set MySQL
/etc/init.d/mysql restart
mysqladmin -u root password 'root'

doCreate() {
  if [ -f /app/Package.swift ];
  then
    cd /app
    chmod +x builder.sh
    swift build --fetch
    rm -rf Packages/*/Tests
    swift build -Xcc -fblocks
    .build/debug/Test
  fi
}

# Retry
RETRIES=0
KEEPGOING=1

# Sleep till file exists
while ! [ -f /app/Package.swift ];
do
  let RETRIES=RETRIES+1
  sleep 1

  if [[ $RETRIES = 20 ]];
  then
    KEEPGOING=0
  fi

  if [[ $KEEPGOING = 0 ]]; then
    exit
  fi
done

# Do the changes
doCreate
