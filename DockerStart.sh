#!/bin/bash

# Kill old ones
docker stop kitura
docker ps -a | grep 'Exited' | awk '{print $1}' | xargs docker rm

# Build a new image
docker build -t kitura-example .

CODEPATH=$(pwd)/Code

# Run the image
docker run \
  -d \
  -P \
  --name kitura \
  -p 80:80 \
  -p 3306:3306 \
  -p 2222:22 \
  -v $CODEPATH:/app \
  kitura-example

# To make sure its running
docker ps -a

# Launch into the image incase you need to change stuff on fly
docker exec -i -t kitura bash
