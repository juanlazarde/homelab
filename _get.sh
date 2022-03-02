#!/usr/bin/env bash
# chmod u+x _get.sh

[[ -n "${1:-}" ]] && curl -fsJO "https://raw.githubusercontent.com/juanlazarde/homelab/main/scripts/${1:-}.sh"
