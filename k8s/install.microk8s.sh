#!/bin/bash

# install microk8s and helm on Debian 11 - RaspiBlitz

if [ "$1" = on ]; then
  sudo adduser --disabled-password --gecos "" k8s
  echo '/usr/share/doc/fzf/examples/key-bindings.bash' >> ~/.bashrc
  echo '/usr/share/doc/fzf/examples/completion.bash' >> ~/.bashrc

  sudo usermod -a -G sudo,bitcoin,debian-tor k8s

  sudo su - k8s

  # https://www.server-world.info/en/note?os=Debian_11&p=microk8s&f=1

  sudo apt update

  SSDmount="/mnt/ext"
  sudo mkdir -p /var/snap
  sudo mv -f /var/snap ${SSDmount}/
  sudo ln -s ${SSDmount}/snap /var/snap

  sudo apt install -y snapd
  sudo snap install microk8s --classic

  echo 'export PATH=/snap/bin:$PATH' >> ~/.bashrc
  source ~/.bashrc

  sudo usermod -a -G microk8s k8s
  sudo chown -f -R k8s ~/.kube
  newgrp microk8s

  # microk8s.inspect
  # troubleshooting steps on Debian
  # https://microk8s.io/docs/troubleshooting
  sudo iptables -P FORWARD ACCEPT
  sudo apt-get install -y iptables-persistent
  echo '{
      "insecure-registries" : ["localhost:32000"]
  }
  ' | sudo tee -a /etc/docker/daemon.json

  sudo ufw allow in on vxlan.calico && sudo ufw allow out on vxlan.calico
  sudo ufw allow in on cali+ && sudo ufw allow out on cali+
  sudo ufw allow 16443 comment "microk8s"
  sudo ufw allow 10443 comment "kubernetes-dashboard"

  SSDmount="/mnt/ext"
  ## part of the docker install script
  # echo "### 3) Symlink the working directory to the SSD"
  sudo systemctl stop docker
  sudo systemctl stop docker.socket
  sudo mkdir -p /var/lib/docker
  sudo mv -f /var/lib/docker ${SSDmount}/
  sudo ln -s ${SSDmount}/docker /var/lib/docker
  sudo systemctl start docker
  sudo systemctl start docker.socket

  microk8s stop

  ## symlink the microk8s containerd and default-storage to the SSD
  SSDmount="/mnt/ext"

  sudo mkdir -p ${SSDmount}/microk8s/common/var/lib/containerd
  sudo mkdir -p ${SSDmount}/microk8s/common/run/containerd

  echo "--config \${SNAP_DATA}/args/containerd.toml
--root ${SSDmount}/microk8s/common/var/lib/containerd
--state ${SSDmount}/microk8s/common/run/containerd
--address \${SNAP_COMMON}/run/containerd.sock
" | sudo tee /var/snap/microk8s/current/args/containerd

  microk8s start

  microk8s enable helm
  microk8s enable dns
  microk8s enable dashboard
  microk8s enable storage
  microk8s enable ingress
  microk8s enable registry

  # make the config permanent
  microk8s config > ~/.kube/config
  sudo chmod 0600 /home/k8s/.kube/config

  # helm
  sudo snap install helm --classic
fi

if [ "$1" = off ]; then

 helm uninstall galoy
 sudo snap remove helm
 microk8s reset [--destroy-storage]
 microk8s stop
 sudo snap remove microk8s
 sudo apt remove -y snapd --purge

fi