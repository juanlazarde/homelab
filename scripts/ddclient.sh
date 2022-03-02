#!/usr/bin/env bash
# Install DDClient Containerized
set -o errexit

# Variables
read -p "Install Docker/Docker Compose? [y|N]: " yn
case $yn in
    [Yy]*)  install_docker=true ;;
    [Nn]*)  install_docker=false ;;
    *)      install_docker=false ;;
esac

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
[[ -f "docker-compose.yaml"]] && cp docker-compose.yaml{,.bak}

cat <<EOF > docker-compose.yaml
---
version: '2.1'
services:
  ddclient:
    image: lscr.io/linuxserver/ddclient
    container_name: ddclient
    environment:
      - PUID=${USER_ID}
      - PGID=${GROUP_ID}
      - TZ=${TIME_ZONE}
    volumes:
      - ./ddclient:/config
    restart: unless-stopped

EOF

# post processing
cp ./ddclient/ddclient.conf{,.bak}

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
