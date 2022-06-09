#!/bin/bash

function help() {
  echo "
Script to set up a local enviroment to run https://github.com/GaloyMoney/charts/tree/main/dev
Usage:
devenv.k3d.sh [on|off]"
  exit 1
}

function setup_devenv_k3d() {
# dedicated user
sudo adduser --disabled-password --gecos "" k3d
sudo usermod -aG sudo k3d
# aliases and fzf
echo '\
/usr/share/doc/fzf/examples/key-bindings.bashrc
/usr/share/doc/fzf/examples/completion.bash
export KUBE_CONFIG_PATH=~/.kube/config' \
 | sudo -u k3d tee -a /home/k3d/.bashrc

echo "\
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias g='git'
alias grep='grep --color=auto'
alias gs='git status'
alias k='kubectl'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias tf='terraform'" \
 | sudo -u k3d tee -a /home/k3d/.bash_aliases

# kubectl
kubectl_version="1.21.9"
curl -LO https://storage.googleapis.com/kubernetes-release/release/v${kubectl_version}/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin

# bitcoin
bitcoin_version="22.0"
wget https://bitcoincore.org/bin/bitcoin-core-${bitcoin_version}/bitcoin-${bitcoin_version}-x86_64-linux-gnu.tar.gz \
  && tar -xvf bitcoin-${bitcoin_version}-x86_64-linux-gnu.tar.gz \
  && sudo mv bitcoin-${bitcoin_version}/bin/* /usr/local/bin

# docker
# https://docs.docker.com/desktop/linux/install/debian/
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo groupadd docker
sudo usermod -aG docker k3d

# k3d
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# starting the charts
cd /home/k3d/
sudo -u k3d git clone  https://github.com/GaloyMoney/charts
cd /home/k3d/charts/dev

sudo -u k3d direnv allow
sudo -u k3d make create-cluster
sudo -u k3d make init
sudo -u k3d bash -c 'export KUBE_CONFIG_PATH=~/.kube/config; make deploy-services'
sudo -u k3d bash -c 'export KUBE_CONFIG_PATH=~/.kube/config; make deploy'
}

function delete_cluster() {
  ## REMOVE
  cd /home/k3d/charts/dev
  make delete-cluster
  # k3d cluster delete && rm terraform.tfstate
}

if [ "$1" = "1" ] || [ "$1" = "on" ]; then
  setup_devenv_k3d
elif [ "$1" = "0" ] || [ "$1" = "off" ]; then
  delete_cluster
else
  help
fi
