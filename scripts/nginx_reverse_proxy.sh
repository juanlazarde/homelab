#!/usr/bin/env bash
# Install NGINX Reverse Proxy Containerized
set -o errexit

# Variables
read -p "Install Docker/Docker Compose? [y|N]: " yn
case $yn in
    [Yy]*)  install_docker=true ;;  
    [Nn]*)  install_docker=false ;;
    *)      install_docker=false ;;
esac

read -p "External Port Nr [12320]: " EXTERNAL_ADMIN_PORT
EXTERNAL_ADMIN_PORT=${EXTERNAL_ADMIN_PORT:-'12320'}

read -p "MySQL Database name [npm]: " DB_MYSQL_NAME
DB_MYSQL_NAME=${DB_MYSQL_NAME:-'npm'}

read -p "MySQL User name [npm]: " DB_MYSQL_USER
DB_MYSQL_USER=${DB_MYSQL_USER:-'npm'}

printf '%s' "MYSQL user "
DB_MYSQL_PASSWORD=$(openssl passwd -6 -noverify | xargs printf '%s' | sed 's/\$/$$/g')
[[ -z "${DB_MYSQL_PASSWORD}" || "${DB_MYSQL_PASSWORD}" == "<NULL>" ]] && printf '%s\n' "Don't leave blank passwords" && exit 1;

printf '%s' "MYSQL root "
MYSQL_ROOT_PASSWORD=$(openssl passwd -6 -noverify | xargs printf '%s' | sed 's/\$/$$/g')
[[ -z "${MYSQL_ROOT_PASSWORD}" || "${MYSQL_ROOT_PASSWORD}" == "<NULL>" ]] && printf '%s\n' "Don't leave blank passwords" && exit 1;

if ${install_docker}; then source docker.sh; fi

# Docker Compose script
cat <<EOF > docker-compose.yaml
---
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy-manager
    ports:
      - '80:80'
      - '${EXTERNAL_ADMIN_PORT}:81'
      - '443:443'
    environment:
      DB_MYSQL_HOST: 'db'
      DB_MYSQL_PORT: 3306
      DB_MYSQL_USER: '${DB_MYSQL_USER}'
      DB_MYSQL_PASSWORD: '${DB_MYSQL_PASSWORD}'
      DB_MYSQL_NAME: '${DB_MYSQL_NAME}'
    volumes:
      - ./nginx/data:/data
      - ./nginx/letsencrypt:/etc/letsencrypt
    restart: unless-stopped
  db:
    image: 'jc21/mariadb-aria:latest'
    container_name: mariadb
    environment:
      MYSQL_ROOT_PASSWORD: '${MYSQL_ROOT_PASSWORD}'
      MYSQL_DATABASE: '${DB_MYSQL_NAME}'
      MYSQL_USER: '${DB_MYSQL_USER}'
      MYSQL_PASSWORD: '${DB_MYSQL_PASSWORD}'
    volumes:
      - ./nginx/data/mysql:/var/lib/mysql
    restart: unless-stopped

EOF

cat "docker-compose.yaml"
printf '%s\n' \
"
--- Final thoughts ---
Visit http://<host>:${EXTERNAL_ADMIN_PORT}

Default login:
  Email:    admin@example.com
  Password: changeme

To make changes to the container:
  docker stop \$(docker ps -aq) && docker rm \$(docker ps -aq)
  nano docker-composer.yaml
  docker-compose up -d
"
