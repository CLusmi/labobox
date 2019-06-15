#!/bin/bash

USER=labobox

echo ""
echo -e "\033[36mARRET des containers ...\033[0m"
echo ""
read -p "Appuyez sur une touche pour CONTINUER."
echo ""
docker stop heimdall
docker stop portainer
docker stop rtorrentvpn
docker stop jackett
docker stop sonarr
docker stop radarr
docker stop plex
docker stop ombi
docker stop tautulli
docker stop watchtower

echo ""
echo -e "\033[36mSUPPRESSION des containers ...\033[0m"
echo ""
read -p "Appuyez sur une touche pour CONTINUER."
echo ""
docker rm heimdall
docker rm portainer
docker rm rtorrentvpn
docker rm jackett
docker rm sonarr
docker rm radarr
docker rm plex
docker rm ombi
docker rm tautulli
docker rm watchtower

echo ""
echo -e "\033[36mSUPPRESSION des images ...\033[0m"
echo ""
read -p "Appuyez sur une touche pour CONTINUER."
echo ""
docker rmi linuxserver/heimdall
docker rmi portainer/portainer
docker rmi binhex/arch-rtorrentvpn
docker rmi linuxserver/jackett
docker rmi linuxserver/sonarr
docker rmi linuxserver/radarr
docker rmi plexinc/pms-docker
docker rmi linuxserver/ombi
docker rmi linuxserver/tautulli
docker rmi containrrr/watchtower

echo ""
echo -e "\033[36mSUPPRESSION de notre utilisateur ...\033[0m"
echo ""
read -p "Appuyez sur une touche pour CONTINUER."
echo ""
deluser $USER
rm -rf /home/$USER
rm -rf /opt/labobox
cd /

echo ""
echo -e "\033[36mL'utilisateur -- \033[35m$USER \033[36m-- a bien été supprimé.\033[0m"
echo ""
echo -e "\033[36mBRAVO ! \033[35mLabobox \033[36ma ete entièrement supprimée.\033[0m"
echo ""
