# homelab
Scripts and tools to setup and run the homelab server

# Configuration for workstation
## FQDN and other shortcuts to connect to servers
Add to `~./ssh/config`
    
    Host docker
        HostName 192.168.3.1
        User admin
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
        Port 22

## Send file from workstation to server

    scp -i ~/.ssh/id_ed25519 get.sh zeus@dev:/home/zeus/

## Download scripts from this repository

    git clone curl -fsJO "https://raw.githubusercontent.com/juanlazarde/homelab/main/scripts/${1:-}.sh"

or

    bash get.sh heimdall
    
