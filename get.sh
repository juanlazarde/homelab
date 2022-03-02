#!/usr/bin/env bash
# usage: bash get.sh heimdall
# purpose: being lazy and not wanting to write that whole address down for every new host created

# chmod u+x _get.sh # to avoid writing bash ..., but ./

[[ -n "${1:-}" ]] && curl -fsJO "https://raw.githubusercontent.com/juanlazarde/homelab/main/scripts/${1:-}.sh"
