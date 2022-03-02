#!/usr/bin/env bash
# Update docker images and containers
set -o errexit

# if host gives error, try
# sudo dpkg-reconfigure openssh-server

if [[ -n "${1}" ]]; then
  ssh-copy-id -i ~/.ssh/id_ed25519 ${1-}
  ssh ${1-}
fi
