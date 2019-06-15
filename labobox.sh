#!/bin/bash

###################################
#Installation du strict necessaire#
###################################

#Variables
USER=labobox
ADDRESS=`wget -qO- ipv4.icanhazip.com`

#Controle si ROOT
if [ "$(id -u)" != "0" ]; then
   echo -e "\033[31mCe script doit etre lancé en ROOT\033[0m" 1>&2
   exit 1
fi

#Mise a jour du serveur
apt-get update && apt-get upgrade -y
sleep 5
dpkg-reconfigure locales
sleep 5
apt-get update && apt-get upgrade -y
sleep 5
apt-get install apt-transport-https sudo git-core curl zip unzip fail2ban htop nano ffmpeg apache2-utils ipcalc -y

#Activation /sbin/modprobe iptable_mangle
#mkdir /boot/config
#cp -r includes/go /boot/config

#Récuperation de l'IP LAN_NETWORK pour "rtorrentvpn"
file=/etc/network/interfaces
netmask=$(awk '/netmask/ {print $2}' $file)
ip=$(awk '/address/ {print $2}' $file)
network=$(ipcalc $ip $netmask | awk '/Network/ {print $2}' | cut -d/ -f1)

########################
#Installation de Docker#
########################

echo ""
echo -e "\033[36m####  DOCKER & DOCKER-COMPOSE  ####\033[0m"
echo ""
	dpkg-query -l docker > /dev/null 2>&1
	if [ $? != 0 ]; then
		echo -e "\033[36m####  INSTALLATION DE DOCKER  ####\033[0m"
		echo ""
		read -p "Appuyez sur une touche pour CONTINUER"
		echo ""
		curl -fsSL https://get.docker.com -o get-docker.sh
		sh get-docker.sh
		if [[ "$?" == "0" ]]; then
		echo -e "\033[32m** Installation de Docker réussie **\033[0m"
		echo ""
	else
		echo -e "\033[31m** Echec de l'installation de Docker **\033[0m"
		echo ""
	fi
        	service docker start > /dev/null 2>&1
        	echo -e "\033[36m####  INSTALLATION DE DOCKER-COMPOSE  ####\033[0m"
		echo ""
        	read -p "Appuyez sur une touche pour CONTINUER"
		echo ""
        	curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        	chmod +x /usr/local/bin/docker-compose
		if [[ "$?" == "0" ]]; then
        	echo -e "\033[32m** Installation de Docker-Compose RÉUSSIE **\033[0m"
		echo ""
	else
        	echo -e "\033[31m** Echec de l'installation Docker-Compose **\033[0m"
		echo ""
	fi
	else
        	echo -e "\033[33m** Docker est deja installé **\033[0m"
		echo ""
        	read -p "Appuyez sur une touche pour CONTINUER"
		echo ""
		echo -e "\033[36m** Voici les containers deja installés **\033[0m"
		echo ""
		docker ps
        	echo ""
        	read -p "Appuyez sur une touche pour CONTINUER"
        	echo ""
	fi

echo -e "\033[36m** Redémarrage de Docker **\033[0m"
echo ""
/etc/init.d/docker restart

############################
#Installation de la Seedbox#
############################

echo ""
echo -e "\033[36m ####  INSTALLATION DE VOTRE SEEDBOX  #### \033[0m"
echo ""
read -p "Appuyez sur une touche pour CONTINUER"
echo ""
echo -e "\033[36m** Création de l'utilisateur -- \033[35mlabobox \033[36m-- **\033[0m"
echo ""
	adduser $USER
echo ""
echo -e "\033[36m** Modification de l'\033[35mUID \033[36met du \033[35mGID \033[36mpour \033[35mlabobox \033[36m**\033[0m"

	usermod -u 1999 $USER
	groupmod -g 1999 $USER
	usermod -aG docker $USER
	cp -r docker_apps /home/$USER
	
echo ""
read -p "Appuyez sur une touche pour installer les applications"
echo ""
		echo -e "\033[33m***** Un token est nécéssaire pour AUTHENTIFIER le serveur Plex *****\033[0m"
		echo -e "\033[33m****    Pour l'obtenir, rendez-vous sur l'adresse suivante :     ****\033[0m"
		echo -e "\033[36m                    https://www.plex.tv/claim/\033[0m"
		echo -e "\033[33m                       Collez-le ci-dessous \033[0m"
		echo ""
		read -rp "CLAIM = " CLAIM
		if [ -n "$CLAIM" ]
		then
			sed -i "s|%CLAIM%|$CLAIM|g" /home/$USER/docker_apps/plex/docker-compose.yml
		fi
		echo ""
		echo -e "\033[33m*****             Votre token a bien été ajouté                 *****\033[0m"
		
	cd /home/$USER/docker_apps/plex && COMPOSE_HTTP_TIMEOUT=480 docker-compose up -d

	cd /home/$USER/docker_apps/heimdall && COMPOSE_HTTP_TIMEOUT=480 docker-compose up -d
	
	cd /home/$USER/docker_apps/portainer && COMPOSE_HTTP_TIMEOUT=480 docker-compose up -d
	
	sed -i "s|%network%|$network|g" /home/labobox/docker_apps/rtorrentvpn/docker-compose.yml
	cd /home/$USER/docker_apps/rtorrentvpn && COMPOSE_HTTP_TIMEOUT=480 docker-compose up -d
	
	cd /home/$USER/docker_apps/jackett && COMPOSE_HTTP_TIMEOUT=480 docker-compose up -d
	
	cd /home/$USER/docker_apps/radarr && COMPOSE_HTTP_TIMEOUT=480 docker-compose up -d
	
	cd /home/$USER/docker_apps/sonarr && COMPOSE_HTTP_TIMEOUT=480 docker-compose up -d
	
	cd /home/$USER/docker_apps/ombi && COMPOSE_HTTP_TIMEOUT=480 docker-compose up -d
	
	cd /home/$USER/docker_apps/tautulli && COMPOSE_HTTP_TIMEOUT=480 docker-compose up -d
	
	cd /home/$USER/docker_apps/watchtower && COMPOSE_HTTP_TIMEOUT=480 docker-compose up -d
	
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/01_temp_seedbox
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/01_temp_seedbox/films
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/01_temp_seedbox/series
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/01_temp_seedbox/autres
	
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/02_actif_seedbox/
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/02_actif_seedbox/films
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/02_actif_seedbox/series
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/02_actif_seedbox/autres
	
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/watch
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/watch/films
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/watch/series
	mkdir /home/$USER/docker_apps/rtorrentvpn/data/torrents/watch/autres
	
	chown -R $USER:$USER /home/$USER/docker_apps/rtorrentvpn/data

echo ""
echo -e "\033[36m##########################################################\033[0m"
echo ""
echo -e "\033[36m####   L'INSTALLATION DE VOTRE SEEDBOX EST ACCOMPLI   ####\033[0m"
echo ""
echo -e "\033[36m##########################################################\033[0m"
echo ""
echo -e "\033[36mPATIENTEZ ENVIRON 5 MINUTES AVANT D'ACCEDER A VOS SERVICES\033[0m"
echo ""
echo -e "\033[36m##########################################################\033[0m"
echo -e "\033[36m##########################################################\033[0m"
echo ""
echo -e "\033[36m* Heimdall            ->   http://$ADDRESS:\033[35m80\033[0m"
echo -e "\033[36m* Portainer           ->   http://$ADDRESS:\033[35m9000\033[0m"
echo -e "\033[36m* ruTorrent           ->   http://$ADDRESS:\033[35m8000\033[0m"
echo -e "\033[36m* Jackett             ->   http://$ADDRESS:\033[35m7000\033[0m"
echo -e "\033[36m* Radarr              ->   http://$ADDRESS:\033[35m7001\033[0m"
echo -e "\033[36m* Sonarr              ->   http://$ADDRESS:\033[35m7002\033[0m"
echo -e "\033[36m* Ombi                ->   http://$ADDRESS:\033[35m7003\033[0m"
echo -e "\033[36m* Tautulli            ->   http://$ADDRESS:\033[35m7004\033[0m"
echo -e "\033[36m* Plex                ->   http://$ADDRESS:\033[35m32400\033[0m"
echo ""
echo -e "\033[36m##########################################################\033[0m"
echo -e "\033[36m##########################################################\033[0m"
echo ""
echo -e "\033[32mMerci d'avoir utilisé https://github.com/CLusmi/labobox\033[0m"
echo ""
#echo -e "Vous devez IMPERATIVEMMENT redemarrer le serveur dans quelques minutes ..."
#read -p "Appuyez sur une touche pour redemarrer"
#reboot
