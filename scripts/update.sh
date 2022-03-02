#!/usr/bin/env bash
# Update docker images and containers
set -o errexit

# installer from https://blog.christophersmart.com/2019/12/15/automatically-updating-containers-with-docker/
cat << \EOF | sudo tee /usr/local/bin/update-containers.sh
#!/bin/bash
 
# Abort on all errors, set -x
set -o errexit
 
# Get the containers from first argument, else get all containers
CONTAINER_LIST="${1:-$(docker ps -q)}"
 
for container in ${CONTAINER_LIST}; do
  # Get the image and hash of the running container
  CONTAINER_IMAGE="$(docker inspect --format "{{.Config.Image}}" --type container ${container})"
  RUNNING_IMAGE="$(docker inspect --format "{{.Image}}" --type container "${container}")"
 
  # Pull in latest version of the container and get the hash
  docker pull "${CONTAINER_IMAGE}"
  LATEST_IMAGE="$(docker inspect --format "{{.Id}}" --type image "${CONTAINER_IMAGE}")"
 
  # Restart the container if the image is different
  if [[ "${RUNNING_IMAGE}" != "${LATEST_IMAGE}" ]]; then
    echo "Updating ${container} image ${CONTAINER_IMAGE}"
    DOCKER_COMMAND="$(runlike "${container}")"
    docker rm --force "${container}"
    eval ${DOCKER_COMMAND}
  fi
done
EOF

sudo chmod a+x /usr/local/bin/update-containers.sh

cat << EOF | sudo tee /etc/systemd/system/update-containers.service 
[Unit]
Description=Update containers
After=network-online.target
 
[Service]
Type=oneshot
ExecStart=/usr/local/bin/update-containers.sh
EOF

cat << EOF | sudo tee /etc/systemd/system/update-containers.timer 
[Unit]
Description=Timer for updating containers
Wants=network-online.target
 
[Timer]
OnActiveSec=24h
OnUnitActiveSec=24h
 
[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl start update-containers.timer
sudo systemctl enable update-containers.timer


sudo systemctl status update-containers.timer
sudo systemctl status update-containers.service
sudo journalctl -u update-containers.service
source /usr/local/bin/update-containers.sh