#!/usr/bin/env bash
# Install Portainer-ce
set -o errexit

# Variables
read -p "Install Docker/Docker Compose? [y|N]: " yn
case $yn in
    [Yy]*)  install_docker=true ;;
    [Nn]*)  install_docker=false ;;
    *)      install_docker=false ;;
esac

if ${install_docker}; then source docker.sh; fi

# Docker Compose script
cat <<EOF > docker-compose.yaml
---
version: '3'
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./portainer:/data
    ports:
      - 9000:9000

EOF

cat "docker-compose.yaml"
printf '%s\n' \
"
--- Final thoughts ---
username: admin

To make changes to the container:
  docker stop \$(docker ps -aq) && docker rm \$(docker ps -aq)
  nano docker-composer.yaml
  docker-compose up -d

  when done:
  docker system prune -a
"
