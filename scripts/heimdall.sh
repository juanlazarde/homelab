#!/usr/bin/env bash
# Install Heimdall launching pad
set -o errexit

# Variables
read -p "Install Docker/Docker Compose? [y|N]: " yn
case $yn in
    [Yy]*)  install_docker=true ;;  
    [Nn]*)  install_docker=false ;;
    *)      install_docker=false ;;
esac

read -p "External Port Nr [9080]: " EXTERNAL_PORT
EXTERNAL_PORT=${EXTERNAL_PORT:-'9080'}

read -p "External SSL Port Nr [9443]: " EXTERNAL_PORT_SSL
EXTERNAL_PORT_SSL=${EXTERNAL_PORT_SSL:-'9443'}

id ${USER}

_UID=$(id -u ${USER})
read -p "User ID [${_UID}]: " USER_ID
USER_ID=${USER_ID:-${_UID}}

_GID=$(id -g ${USER})
read -p "Group ID [${_GID}]: " GROUP_ID
GROUP_ID=${GROUP_ID:-${_GID}}

read -p "Time Zone [America/New_York]: " TIME_ZONE
TIME_ZONE=${TIME_ZONE:-'America/New_York'}

if ${install_docker}; then source docker.sh; fi

# Docker Compose script
cat <<EOF > docker-compose.yaml
---
version: '2.1'
services:
  heimdall:
    image: lscr.io/linuxserver/heimdall
    container_name: heimdall
    environment:
      - PUID=${USER_ID}
      - PGID=${GROUP_ID}
      - TZ=${TIME_ZONE}
    volumes:
      - ./heimdall:/config
    ports:
      - '${EXTERNAL_PORT}:80'
      - '${EXTERNAL_PORT_SSL}:443'
    restart: unless-stopped

EOF

cat "docker-compose.yaml"
printf '%s\n' \
"
--- Final thoughts ---
nano ddclient.conf

Edit:
  daemon=3600
  use=web
  ssl=yes
  protocol=googledomains
  login=generated_username
  password=generated_password
  your_resource.your_domain.tld

To make changes to the container:
  docker stop \$(docker ps -aq) && docker rm \$(docker ps -aq)
  nano docker-composer.yaml
  docker-compose up -d

  when done:
  docker system prune -a
"
