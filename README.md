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

