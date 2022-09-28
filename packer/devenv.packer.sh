#!/bin/bash

function help() {
  echo "
Script to set up a local enviroment to run packer
Usage:
devenv.packer.sh [on|off]"
  exit 1
}

USER="packer"

function setup_devenv_packer() {
  # dedicated user
  sudo adduser --disabled-password --gecos "" ${USER}
  #sudo usermod -aG sudo packer

  # tools
  sudo apt update
  sudo apt install -y git tmux gnupg unzip curl

  # fzf
  sudo -u ${USER} sh -c 'git clone --depth 1 https://github.com/junegunn/fzf.git /home/${USER}/.fzf; /home/${USER}/.fzf/install --all'

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
  sudo usermod -aG docker packer

# Install packer
if ! packer version; then
  echo -e "\nInstalling packer..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update -y && sudo apt-get install packer -y
fi

export PATH=$PATH:/usr/local/go/bin
if ! go version; then
  echo -e "Installing Go..."
  wget --progress=bar:force https://go.dev/dl/go1.18.4.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.18.4.linux-amd64.tar.gz
  sudo rm -rf go1.18.4.linux-amd64.tar.gz
fi

# Install Packer Arm Plugin
echo -e "\nInstalling Packer Arm Plugin..."
cd /home/${USER}
sudo -u ${USER} git clone https://github.com/mkaczanowski/packer-builder-arm
cd packer-builder-arm
sudo -u ${USER} /usr/local/go/bin/go mod download
sudo -u ${USER} /usr/local/go/bin/go build

echo "\
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias g='git'
alias grep='grep --color=auto'
alias gs='git status'
" | sudo -u ${USER} tee -a /home/${USER}/.bash_aliases
}


if [ "$1" = "on" ]; then
  setup_devenv_packer
elif [ "$1" = "off" ]; then
  sudo userdel -rf packer
else
  help
fi
