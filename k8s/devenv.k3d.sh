#!/bin/bash

function help() {
  echo "
Script to set up a local enviroment to run https://github.com/GaloyMoney/charts/tree/main/dev
Usage:
devenv.k3d.sh [setup_devenv_k3d|start_dev_charts|delete_cluster]"
  exit 1
}

function clone_all_galoy() {
  mkdir GaloyMoney && cd GaloyMoney
  # clone all repos
  curl -s https://api.github.com/users/GaloyMoney/repos | grep \"clone_url\" | awk '{print $2}' | sed -e 's/"//g' -e 's/,//g' | xargs -n1 git clone
}

function setup_devenv_k3d() {
  # dedicated user
  sudo adduser --disabled-password --gecos "" k3d
  sudo usermod -aG sudo k3d

  # tools
  sudo apt update
  sudo apt install -y git tmux gnupg unzip curl

  # fzf
  sudo -u k3d sh -c 'git clone --depth 1 https://github.com/junegunn/fzf.git /home/k3d/.fzf; /home/k3d/.fzf/install --all'

  cpu=$(dpkg --print-architecture)

  # kubectl
  if ! kubectl version; then
    kubectl_version="1.24.1"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v${kubectl_version}/bin/linux/${cpu}/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin
  fi

  # terraform
  if ! terraform version; then
    if [ "${cpu}" = amd64 ]; then
      if ! sudo apt install terraform; then
        sudo apt-get install -y software-properties-common
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update
        sudo apt-get install -y terraform
      fi
    elif [ "${cpu}" = arm64 ]; then
      # RPI
      wget -O terraform_1.2.4_linux_arm64.zip https://releases.hashicorp.com/terraform/1.2.4/terraform_1.2.4_linux_arm64.zip || exit 1
      wget https://releases.hashicorp.com/terraform/1.2.4/terraform_1.2.4_SHA256SUMS
      sha256sum -c terraform_1.2.4_SHA256SUMS --ignore-missing || exit 1
      wget https://releases.hashicorp.com/terraform/1.2.4/terraform_1.2.4_SHA256SUMS.sig || exit 1
      gpg --verify terraform_1.2.4_SHA256SUMS.sig || exit 1
      unzip terraform_1.2.4_linux_arm64.zip
      sudo mv ./terraform /usr/local/bin/
    fi
  fi

  ## bitcoin
  #bitcoin_version="22.0"
  #if ! bitcoind --version; then
  #  if [ "${cpu}" = amd64 ]; then
  #    wget https://bitcoincore.org/bin/bitcoin-core-${bitcoin_version}/bitcoin-${bitcoin_version}-x86_64-linux-gnu.tar.gz \
  #      && tar -xvf bitcoin-${bitcoin_version}-x86_64-linux-gnu.tar.gz \
  #      && sudo mv bitcoin-${bitcoin_version}/bin/* /usr/local/bin
  #  fi
  #fi

  # docker
  if ! docker version; then
    # look for raspiblitz install script
    if [ -f /home/admin/config.scripts/blitz.docker.sh ]; then
      /home/admin/config.scripts/blitz.docker.sh on
    else
      # https://docs.docker.com/desktop/linux/install/debian/
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
    fi
  fi
  sudo groupadd docker
  sudo usermod -aG docker k3d

  if ! docker compose version; then
    # docker compose
    # https://docs.docker.com/compose/install/linux/
    sudo apt-get install docker-compose-plugin
    #sudo wget "https://github.com/docker/compose/releases/download/v2.14.1/docker-compose-linux-x86_64" -O /usr/libexec/docker/cli-plugins/docker-compose
    #sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
    #PATH=$PATH:/usr/libexec/docker/cli-plugins
  fi

  # k3d
  if ! k3d version; then
    wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  fi

  # KUBE_CONFIG_PATH
  echo 'export KUBE_CONFIG_PATH=~/.kube/config' \
 | sudo -u k3d tee -a /home/k3d/.bashrc
# aliases
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

if [ "${cpu}" = arm64 ]; then
  # https://code.pinske.eu/k3d-raspi.html
  if ! grep "cgroup_memory=1 cgroup_enable=memory" < /boot/cmdline.txt; then
    sudo sed -i s/$/ cgroup_memory=1 cgroup_enable=memory/ /boot/cmdline.txt
    echo "# Will need to reboot to create a cluster successfully"
  fi
fi
}

function start_dev_charts() {
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
  sudo -u k3d make delete-cluster
  # k3d cluster delete && rm terraform.tfstate
}

if [ "$1" = "setup_devenv_k3d" ]; then
  setup_devenv_k3d
elif [ "$1" = "start_dev_charts" ]; then
  start_dev_charts
elif [ "$1" = "delete_cluster" ]; then
  delete_cluster
else
  help
fi
