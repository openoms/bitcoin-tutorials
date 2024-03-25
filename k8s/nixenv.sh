#!/bin/bash

# dedicated user
USERNAME=k3d
PASSWORD=""

echo "# add the user: ${USERNAME}"
sudo adduser --system --group --shell /bin/bash --home /home/${USERNAME} ${USERNAME}
echo "Copy the skeleton files for login"
sudo -u ${USERNAME} cp -r /etc/skel/. /home/${USERNAME}/
sudo adduser ${USERNAME} sudo

# set a password
echo "$USERNAME:$PASSWORD" | sudo chpasswd


  # docker
  if ! docker version 2>/dev/null; then
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
  sudo usermod -aG docker $USERNAME

# need to log back in to get the group change



# nix
# manual install step
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

echo "$PATH:/nix/var/nix/profiles/default/bin/nix" >> ~/.bashrc

# direnv
sudo apt install -y direnv
echo "eval \"\$(direnv hook bash)\"" >> ~/.bashrc
source ~/.bashrc


sudo su - k3d
https://github.com/GaloyMoney/charts

direnv allow

cd dev
make create-cluster
