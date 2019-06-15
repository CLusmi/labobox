# Script Seedbox via Docker-Compose (mono-user).
- Idéal pour les seedbox sur serveur dédié.

-------------

Testé sur VM Proxmox (qemu), CT Proxmox (LXC), Serveur DEDIE / Debian 9 (stretch)  -> OK (15/06/2019)

-------------

Un USER est créer pendant l'installation. (USER=labobox / UID=1999 / GID=1999)

    Heimdall                  -> image : linuxserver/heimdall:latest
    Portainer                 -> image : portainer/portainer:latest
    rtorrent + ruTorrent      -> image : binhex/arch-rtorrentvpn:latest
    Jackett                   -> image : linuxserver/jackett:latest
    Radarr                    -> image : linuxserver/radarr:latest
    Sonarr                    -> image : linuxserver/sonarr:latest
    Ombi                      -> image : linuxserver/ombi:latest
    Tautulli                  -> image : linuxserver/tautulli:latest
    Plex                      -> image : plexinc/pms-docker:latest
    Watchtower                -> image : containrrr/watchtower:latest

*Prérequis :
-------------------------------------------------------------
* Si votre host est Proxmox, il est imperatif d'activer les modules iptables dans le fichier /etc/modules.

      nano /etc/modules
    
--> Rajoutez : 

    # /etc/modules: kernel modules to load at boot time.
    #
    # This file contains the names of kernel modules that should be loaded
    # at boot time, one per line. Lines beginning with "#" are ignored.

    loop
 
    # Iptables modules to be loaded for the OpenVZ container
    ipt_REJECT
    ipt_recent
    ipt_owner
    ipt_REDIRECT
    ipt_tos
    ipt_TOS
    ipt_LOG
    ip_conntrack
    ipt_limit
    ipt_multiport
    iptable_filter
    iptable_mangle
    ipt_TCPMSS
    ipt_tcpmss
    ipt_ttl
    ipt_length
    ipt_state
    iptable_nat
    ip_nat_ftp
    ipt_MASQUERADE
    
--> Redemarrez votre host Proxmox.

* (Si CT Proxmox, veuillez modifier la configuration de votre CT depuis votre host Proxmox)

      nano /etc/pve/lxc/XXX.conf
      
--> Rajouter à la fin : 
   
    lxc.autodev: 1
    lxc.hook.autodev: sh -c "mknod -m 0666 ${LXC_ROOTFS_MOUNT}/dev/fuse c 10 229"
    lxc.cgroup.devices.allow: c 10:200 rwm
    lxc.apparmor.profile: unconfined
        
   Redemarrer le CT ...
   
* Debian 9.

* Un nom de domaine (ou simplement une IP).

* Un pointage de type A de votre nom de domaine vers l'IP de votre machine.
   
-------------

Toutes ces etapes effectuées, connectez vous à votre machine (VM, CT, ou dédié), puis :

-------------

*Téléchargement du script via GitHub :
-------------------------------------------------------------

    apt-get update && apt-get upgrade -y
    apt-get install git nano -y
    rm -rf cd /opt/labobox
    git clone https://github.com/CLusmi/labobox.git /opt/labobox
    cd /opt/labobox
    chmod 755 labobox.sh laboboxdel.sh

*Installation du script.
-------------------------------------------------------------

    ./labobox.sh
    
*Désinstallation du script.
-------------------------------------------------------------

    ./laboboxdel.sh
    
*ruTorrent
------------------------------------------------------------- 
    
    Login : admin
    Pass  : rutorrent
    
Pour ajouter/supprimer un login : 

    docker exec -it rtorrentvpn /home/nobody/createuser.sh <username a creer>
    docker exec -it rtorrentvpn /home/nobody/deluser.sh <username a supprimer>

*Liez votre compte PLEX via tunnel SSH.
-------------------------------------------------------------

 -> Si la liaison via le "CLAIM" n'a pas fonctionné ...

Sous PUTTY, Entrez votre adresse ip :

https://raw.githubusercontent.com/CLusmi/labobox/master/putty1.jpg

Puis, cliquez sur SSH, puis sur TUNNELS.

Entrez les informations comme ci dessous, puis cliquez sur ADD.

https://raw.githubusercontent.com/CLusmi/labobox/master/putty2.jpg

Enfin, cliquez sur OPEN pour terminer la configuration du tunnel et ouvrir le terminal.

Logguez vous, ouvrez une nouvelle page web via votre navigateur, et rendez vous sur : http://localhost:8888/web

Terminez la configuration de PLEX, et n'oubliez pas d'activer l'accès à distance dans les paramètres du serveur.

Vous pouvez ensuite taper "exit" sur le terminal pour quitter le tunnel SSH.

*Accès aux services installés.
-------------------------------------------------------------

    Heimdall              ->   http://IP:80
    Portainer             ->   http://IP:9000
    ruTorrent             ->   http://IP:8000
    Jackett               ->   http://IP:7000
    Radarr                ->   http://IP:7001
    Sonarr                ->   http://IP:7002
    Ombi                  ->   http://IP:7003
    Tautulli              ->   http://IP:7004
    Plex                  ->   http://IP:32400
